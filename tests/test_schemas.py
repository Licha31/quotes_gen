from decimal import Decimal

import pytest
from pydantic import ValidationError

from app.schemas import QuoteCreate, parse_ars_amount


@pytest.mark.parametrize(
    ("raw_amount", "expected"),
    [
        ("45000", Decimal("45000.00")),
        ("45000,50", Decimal("45000.50")),
        ("45000.50", Decimal("45000.50")),
        ("45.000", Decimal("45000.00")),
        ("45.000,50", Decimal("45000.50")),
        ("1.234.567,89", Decimal("1234567.89")),
    ],
)
def test_parse_ars_amount_accepts_supported_formats(
    raw_amount: str,
    expected: Decimal,
) -> None:
    assert parse_ars_amount(raw_amount) == expected


@pytest.mark.parametrize("raw_amount", ["1.2.3", "1..2,50", "12.34.56"])
def test_parse_ars_amount_rejects_malformed_thousands_separators(
    raw_amount: str,
) -> None:
    with pytest.raises(ValueError, match="importe válido"):
        parse_ars_amount(raw_amount)


def test_quote_number_is_trimmed() -> None:
    data = valid_quote_data()
    data["quote_number"] = "  2026-015  "

    quote = QuoteCreate.model_validate(data)

    assert quote.quote_number == "2026-015"


def test_empty_quote_number_becomes_none() -> None:
    data = valid_quote_data()
    data["quote_number"] = "   "

    quote = QuoteCreate.model_validate(data)

    assert quote.quote_number is None


def test_quote_number_has_a_maximum_length() -> None:
    data = valid_quote_data()
    data["quote_number"] = "A" * 33

    with pytest.raises(ValidationError):
        QuoteCreate.model_validate(data)


def valid_quote_data() -> dict[str, object]:
    return {
        "customer_name": "Carolina Pérez",
        "customer_phone": "264 555 0123",
        "quote_date": "2026-08-19",
        "valid_until": "2026-08-26",
        "items": [
            {
                "description": "Torta personalizada 2 kg",
                "quantity": "1",
                "unit_price": "45.000,00",
            }
        ],
        "discount": "5.000,00",
        "notes": "Entrega por la tarde",
    }


@pytest.mark.parametrize("quantity", ["0", "-1", "1.5"])
def test_quantity_must_be_a_positive_integer(quantity: str) -> None:
    data = valid_quote_data()
    data["items"] = [{**data["items"][0], "quantity": quantity}]

    with pytest.raises(ValidationError):
        QuoteCreate.model_validate(data)


def test_valid_until_cannot_be_before_quote_date() -> None:
    data = valid_quote_data()
    data["valid_until"] = "2026-08-18"

    with pytest.raises(ValidationError, match="no puede ser anterior"):
        QuoteCreate.model_validate(data)


def test_quote_requires_at_least_one_item() -> None:
    data = valid_quote_data()
    data["items"] = []

    with pytest.raises(ValidationError):
        QuoteCreate.model_validate(data)
