from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_new_quote_page_renders() -> None:
    response = client.get("/quotes/new")

    assert response.status_code == 200
    assert "Adrytentaciones" in response.text
    assert "Nuevo presupuesto" in response.text
    assert 'class="quote-workspace"' in response.text
    assert 'name="quote_number"' in response.text
    assert "quote-form.js" in response.text


def test_successful_post_renders_server_calculated_preview() -> None:
    response = client.post(
        "/quotes",
        data={
            "quote_number": "  ADRY-32  ",
            "customer_name": "Carolina Pérez",
            "customer_phone": "264 555 0123",
            "quote_date": "2026-08-19",
            "valid_until": "2026-08-26",
            "item_description": ["12 donas", "Torta personalizada 2 kg"],
            "item_quantity": ["12", "1"],
            "item_unit_price": ["1.500,00", "45.000,00"],
            "discount": "5.000,00",
            "notes": "Entrega por la tarde",
        },
    )

    assert response.status_code == 200
    assert "Presupuesto para Carolina Pérez" in response.text
    assert "ADRY-32" in response.text
    assert "12 donas" in response.text
    assert "Torta personalizada 2 kg" in response.text
    assert "$ 63.000,00" in response.text
    assert "− $ 5.000,00" in response.text
    assert "$ 58.000,00" in response.text
    assert "Descargar PDF" in response.text
    assert 'action="http://testserver/quotes/pdf"' in response.text
    assert response.text.count('name="item_description"') == 2


def test_invalid_post_returns_feedback_and_preserves_values() -> None:
    response = client.post(
        "/quotes",
        data={
            "quote_number": "024",
            "customer_name": "Carolina Pérez",
            "quote_date": "2026-08-19",
            "valid_until": "2026-08-26",
            "item_description": "12 donas",
            "item_quantity": "0",
            "item_unit_price": "1.500,00",
            "discount": "0",
        },
    )

    assert response.status_code == 422
    assert "Revisá los datos del presupuesto" in response.text
    assert "Debe ser mayor que cero." in response.text
    assert 'value="Carolina Pérez"' in response.text
    assert 'value="024"' in response.text
    assert 'value="12 donas"' in response.text


def test_preview_omits_quote_number_when_empty() -> None:
    response = client.post(
        "/quotes",
        data={
            "quote_number": "",
            "customer_name": "Carolina Pérez",
            "quote_date": "2026-08-19",
            "valid_until": "2026-08-26",
            "item_description": "12 donas",
            "item_quantity": "12",
            "item_unit_price": "1.500,00",
            "discount": "0",
        },
    )

    assert response.status_code == 200
    assert "<dt>Número</dt>" not in response.text
    assert "sin número" not in response.text.lower()


def test_discount_greater_than_subtotal_returns_feedback() -> None:
    response = client.post(
        "/quotes",
        data={
            "customer_name": "Carolina Pérez",
            "quote_date": "2026-08-19",
            "valid_until": "2026-08-26",
            "item_description": "Torta personalizada 2 kg",
            "item_quantity": "1",
            "item_unit_price": "45.000,00",
            "discount": "50.000,00",
        },
    )

    assert response.status_code == 422
    assert "El descuento no puede superar el subtotal." in response.text
    assert 'value="50.000,00"' in response.text


def test_post_without_items_shows_validation_feedback() -> None:
    response = client.post(
        "/quotes",
        data={
            "customer_name": "Carolina Pérez",
            "quote_date": "2026-08-19",
            "valid_until": "2026-08-26",
            "discount": "0",
        },
    )

    assert response.status_code == 422
    assert "Agregá al menos un producto." in response.text
    assert 'name="item_description"' in response.text
