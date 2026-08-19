import re
from datetime import date
from decimal import Decimal, InvalidOperation

from pydantic import BaseModel, ConfigDict, Field, ValidationInfo, field_validator

from app.calculations import quantize_money

INTEGER_PATTERN = re.compile(r"^-?\d+$")
ARS_NUMBER_PATTERN = re.compile(
    r"^(?:\d+|\d+[.,]\d{1,2}|\d{1,3}(?:\.\d{3})+(?:,\d{1,2})?)$"
)
ARS_THOUSANDS_PATTERN = re.compile(r"^\d{1,3}(?:\.\d{3})+$")


def parse_ars_amount(value: object) -> Decimal:
    if isinstance(value, float):
        raise ValueError("Los importes no pueden usar números de punto flotante.")
    if isinstance(value, Decimal):
        return quantize_money(value)
    if isinstance(value, int) and not isinstance(value, bool):
        return quantize_money(Decimal(value))
    if not isinstance(value, str):
        raise ValueError("Ingresá un importe válido.")

    text = value.strip().replace("$", "").replace(" ", "")
    if not text:
        raise ValueError("Ingresá un importe válido.")

    sign = ""
    if text.startswith("-"):
        sign = "-"
        text = text[1:]
    if not text:
        raise ValueError("Ingresá un importe válido.")

    if not ARS_NUMBER_PATTERN.fullmatch(text):
        raise ValueError("Ingresá un importe válido.")

    if "," in text:
        normalized_number = text.replace(".", "").replace(",", ".")
    elif ARS_THOUSANDS_PATTERN.fullmatch(text):
        normalized_number = text.replace(".", "")
    else:
        normalized_number = text

    try:
        return quantize_money(Decimal(f"{sign}{normalized_number}"))
    except InvalidOperation as error:
        raise ValueError("Ingresá un importe válido.") from error


def parse_integer(value: object) -> int:
    if isinstance(value, bool):
        raise ValueError("Ingresá un número entero.")
    if isinstance(value, int):
        return value
    if isinstance(value, str) and INTEGER_PATTERN.fullmatch(value.strip()):
        return int(value)
    raise ValueError("Ingresá un número entero.")


class QuoteItemCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    description: str = Field(min_length=1)
    quantity: int = Field(gt=0)
    unit_price: Decimal = Field(ge=0, allow_inf_nan=False)

    @field_validator("quantity", mode="before")
    @classmethod
    def validate_quantity(cls, value: object) -> int:
        return parse_integer(value)

    @field_validator("unit_price", mode="before")
    @classmethod
    def validate_unit_price(cls, value: object) -> Decimal:
        return parse_ars_amount(value)


class QuoteCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    quote_number: str | None = Field(default=None, max_length=32)
    customer_name: str = Field(min_length=1)
    customer_phone: str | None = None
    quote_date: date
    valid_until: date
    items: list[QuoteItemCreate] = Field(min_length=1)
    discount: Decimal = Field(default=Decimal("0"), ge=0, allow_inf_nan=False)
    notes: str | None = None

    @field_validator("quote_number", "customer_phone", "notes", mode="before")
    @classmethod
    def empty_optional_text_is_none(cls, value: object) -> object:
        if isinstance(value, str) and not value.strip():
            return None
        return value

    @field_validator("valid_until")
    @classmethod
    def valid_until_is_not_before_quote_date(
        cls,
        value: date,
        info: ValidationInfo,
    ) -> date:
        quote_date = info.data.get("quote_date")
        if quote_date is not None and value < quote_date:
            raise ValueError("La fecha de validez no puede ser anterior a la fecha.")
        return value

    @field_validator("discount", mode="before")
    @classmethod
    def validate_discount(cls, value: object) -> Decimal:
        if value is None or (isinstance(value, str) and not value.strip()):
            return Decimal("0")
        return parse_ars_amount(value)
