from fastapi.testclient import TestClient

import app.main as main_module
from app.main import app

client = TestClient(app)
FAKE_PDF = b"%PDF-1.7\nPDF test content"


def valid_pdf_data(quote_number: str = "024") -> dict[str, object]:
    return {
        "quote_number": quote_number,
        "customer_name": "Carolina Pérez",
        "customer_phone": "264 555 0123",
        "quote_date": "2026-08-19",
        "valid_until": "2026-08-26",
        "item_description": ["12 donas", "Torta personalizada 2 kg"],
        "item_quantity": ["12", "1"],
        "item_unit_price": ["1.500,00", "45.000,00"],
        "discount": "5.000,00",
        "notes": "Entrega por la tarde",
    }


def test_pdf_endpoint_returns_numbered_attachment(monkeypatch) -> None:
    async def fake_generate_pdf(html: str) -> bytes:
        assert "Adrytentaciones" in html
        return FAKE_PDF

    monkeypatch.setattr(main_module, "generate_pdf", fake_generate_pdf)

    response = client.post("/quotes/pdf", data=valid_pdf_data())

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert response.headers["content-disposition"] == (
        'attachment; filename="presupuesto-024.pdf"'
    )
    assert response.content.startswith(b"%PDF-")


def test_pdf_filename_uses_customer_when_number_is_empty(monkeypatch) -> None:
    async def fake_generate_pdf(html: str) -> bytes:
        return FAKE_PDF

    monkeypatch.setattr(main_module, "generate_pdf", fake_generate_pdf)

    response = client.post("/quotes/pdf", data=valid_pdf_data(quote_number=""))

    assert response.status_code == 200
    assert response.headers["content-disposition"] == (
        'attachment; filename="presupuesto-carolina-perez.pdf"'
    )


def test_invalid_quote_does_not_generate_pdf(monkeypatch) -> None:
    pdf_was_requested = False

    async def fake_generate_pdf(html: str) -> bytes:
        nonlocal pdf_was_requested
        pdf_was_requested = True
        return FAKE_PDF

    monkeypatch.setattr(main_module, "generate_pdf", fake_generate_pdf)
    data = valid_pdf_data()
    data["item_quantity"] = ["0", "1"]

    response = client.post("/quotes/pdf", data=data)

    assert response.status_code == 422
    assert "Debe ser mayor que cero." in response.text
    assert pdf_was_requested is False


def test_pdf_recalculates_totals_and_ignores_submitted_totals(monkeypatch) -> None:
    rendered_html = ""

    async def capture_pdf_html(html: str) -> bytes:
        nonlocal rendered_html
        rendered_html = html
        return FAKE_PDF

    monkeypatch.setattr(main_module, "generate_pdf", capture_pdf_html)
    data = valid_pdf_data()
    data.update(
        {
            "subtotal": "1,00",
            "total": "1,00",
            "discount": "0",
        }
    )

    response = client.post("/quotes/pdf", data=data)

    assert response.status_code == 200
    assert "$ 63.000,00" in rendered_html
    assert "$ 1,00" not in rendered_html


def test_pdf_endpoint_generates_a_real_pdf_with_chromium() -> None:
    response = client.post("/quotes/pdf", data=valid_pdf_data())

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert response.content.startswith(b"%PDF-")
