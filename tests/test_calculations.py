from decimal import Decimal

import pytest

from app.calculations import (
    calculate_final_total,
    calculate_item_subtotal,
    calculate_quote_subtotal,
    format_ars,
)


def test_item_subtotal() -> None:
    subtotal = calculate_item_subtotal(12, Decimal("1500.00"))

    assert subtotal == Decimal("18000.00")


def test_quote_subtotal() -> None:
    subtotal = calculate_quote_subtotal([Decimal("18000.00"), Decimal("45000.00")])

    assert subtotal == Decimal("63000.00")


def test_fixed_discount_and_final_total() -> None:
    total = calculate_final_total(Decimal("80000.00"), Decimal("5000.00"))

    assert total == Decimal("75000.00")


def test_multiple_items_use_decimal_calculations() -> None:
    item_subtotals = [
        calculate_item_subtotal(12, Decimal("1500.00")),
        calculate_item_subtotal(1, Decimal("45000.00")),
        calculate_item_subtotal(2, Decimal("7250.50")),
    ]

    subtotal = calculate_quote_subtotal(item_subtotals)

    assert subtotal == Decimal("77501.00")
    assert format_ars(subtotal) == "$ 77.501,00"


def test_discount_cannot_exceed_subtotal() -> None:
    with pytest.raises(ValueError, match="no puede superar"):
        calculate_final_total(Decimal("1000.00"), Decimal("1000.01"))
