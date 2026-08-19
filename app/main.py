from decimal import Decimal
from pathlib import Path
from typing import Any

from fastapi import FastAPI, Request, status
from fastapi.responses import Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pydantic import ValidationError
from starlette.datastructures import FormData

from app.calculations import (
    calculate_final_total,
    calculate_item_subtotal,
    calculate_quote_subtotal,
    format_ars,
)
from app.pdf import build_pdf_filename, generate_pdf, load_pdf_assets
from app.schemas import QuoteCreate

APP_DIR = Path(__file__).resolve().parent

app = FastAPI(title="Presupuestador Adrytentaciones")
app.mount("/static", StaticFiles(directory=APP_DIR / "static"), name="static")

templates = Jinja2Templates(directory=APP_DIR / "templates")


def _empty_item() -> dict[str, str]:
    return {"description": "", "quantity": "1", "unit_price": ""}


def _empty_form() -> dict[str, Any]:
    return {
        "quote_number": "",
        "customer_name": "",
        "customer_phone": "",
        "quote_date": "",
        "valid_until": "",
        "items": [_empty_item()],
        "discount": "",
        "notes": "",
    }


def _string_value(form: FormData, key: str) -> str:
    value = form.get(key, "")
    return value if isinstance(value, str) else ""


def _string_list(form: FormData, key: str) -> list[str]:
    return [value for value in form.getlist(key) if isinstance(value, str)]


def _form_values(form: FormData) -> dict[str, Any]:
    descriptions = _string_list(form, "item_description")
    quantities = _string_list(form, "item_quantity")
    unit_prices = _string_list(form, "item_unit_price")
    item_count = max(len(descriptions), len(quantities), len(unit_prices))

    items = [
        {
            "description": descriptions[index] if index < len(descriptions) else "",
            "quantity": quantities[index] if index < len(quantities) else "",
            "unit_price": unit_prices[index] if index < len(unit_prices) else "",
        }
        for index in range(item_count)
    ]

    return {
        "quote_number": _string_value(form, "quote_number"),
        "customer_name": _string_value(form, "customer_name"),
        "customer_phone": _string_value(form, "customer_phone"),
        "quote_date": _string_value(form, "quote_date"),
        "valid_until": _string_value(form, "valid_until"),
        "items": items,
        "discount": _string_value(form, "discount"),
        "notes": _string_value(form, "notes"),
    }


def _error_message(error: dict[str, Any]) -> str:
    error_type = error["type"]
    messages = {
        "date_from_datetime_parsing": "Ingresá una fecha válida.",
        "date_from_date_parsing": "Ingresá una fecha válida.",
        "decimal_parsing": "Ingresá un importe válido.",
        "decimal_type": "Ingresá un importe válido.",
        "greater_than": "Debe ser mayor que cero.",
        "greater_than_equal": "No puede ser negativo.",
        "int_parsing": "Ingresá un número entero.",
        "int_type": "Ingresá un número entero.",
        "list_too_short": "Agregá al menos un producto.",
        "missing": "Este campo es obligatorio.",
        "string_too_short": "Este campo es obligatorio.",
        "string_too_long": "Usá como máximo 32 caracteres.",
        "too_short": "Agregá al menos un producto.",
    }
    if error_type == "value_error":
        return str(error["msg"]).removeprefix("Value error, ")
    return messages.get(error_type, "Revisá este valor.")


def _validation_errors(exception: ValidationError) -> dict[str, str]:
    errors: dict[str, str] = {}
    for error in exception.errors(include_url=False):
        location = error["loc"]
        if len(location) >= 3 and location[0] == "items":
            key = f"items.{location[1]}.{location[2]}"
        elif location:
            key = str(location[-1])
        else:
            key = "form"
        errors.setdefault(key, _error_message(error))
    return errors


def _form_context(form: dict[str, Any], errors: dict[str, str]) -> dict[str, Any]:
    display_form = {**form}
    display_form["items"] = form["items"] or [_empty_item()]
    return {
        "form": display_form,
        "errors": errors,
        "zero_amount": format_ars(Decimal("0")),
    }


def _quote_context(quote: QuoteCreate) -> dict[str, Any]:
    item_subtotals = [
        calculate_item_subtotal(item.quantity, item.unit_price) for item in quote.items
    ]
    subtotal = calculate_quote_subtotal(item_subtotals)
    total = calculate_final_total(subtotal, quote.discount)
    items = [
        {
            "description": item.description,
            "quantity": item.quantity,
            "unit_price": format_ars(item.unit_price),
            "subtotal": format_ars(item_subtotal),
        }
        for item, item_subtotal in zip(quote.items, item_subtotals, strict=True)
    ]
    return {
        "quote": quote,
        "items": items,
        "quote_date": quote.quote_date.strftime("%d/%m/%Y"),
        "valid_until": quote.valid_until.strftime("%d/%m/%Y"),
        "subtotal": format_ars(subtotal),
        "discount": format_ars(quote.discount),
        "total": format_ars(total),
    }


@app.get("/quotes/new", name="new_quote")
def new_quote(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="quotes/new.html",
        context=_form_context(_empty_form(), {}),
    )


@app.post("/quotes", name="create_quote")
async def create_quote(request: Request):
    submitted_form = await request.form()
    form = _form_values(submitted_form)

    try:
        quote = QuoteCreate.model_validate(form)
    except ValidationError as exception:
        return templates.TemplateResponse(
            request=request,
            name="quotes/new.html",
            context=_form_context(form, _validation_errors(exception)),
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        )

    try:
        quote_context = _quote_context(quote)
    except ValueError as error:
        return templates.TemplateResponse(
            request=request,
            name="quotes/new.html",
            context=_form_context(form, {"discount": str(error)}),
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        )

    return templates.TemplateResponse(
        request=request,
        name="quotes/preview.html",
        context=quote_context,
    )


@app.post("/quotes/pdf", name="download_quote_pdf")
async def download_quote_pdf(request: Request):
    submitted_form = await request.form()
    form = _form_values(submitted_form)

    try:
        quote = QuoteCreate.model_validate(form)
    except ValidationError as exception:
        return templates.TemplateResponse(
            request=request,
            name="quotes/new.html",
            context=_form_context(form, _validation_errors(exception)),
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        )

    try:
        quote_context = _quote_context(quote)
    except ValueError as error:
        return templates.TemplateResponse(
            request=request,
            name="quotes/new.html",
            context=_form_context(form, {"discount": str(error)}),
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        )

    pdf_css, nunito_font = load_pdf_assets(APP_DIR / "static")
    html = templates.get_template("quotes/pdf.html").render(
        **quote_context,
        pdf_css=pdf_css,
        nunito_font=nunito_font,
    )
    pdf_bytes = await generate_pdf(html)
    filename = build_pdf_filename(quote.quote_number, quote.customer_name)

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
