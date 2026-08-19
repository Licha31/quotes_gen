from collections.abc import Iterable
from decimal import ROUND_HALF_UP, Decimal

CENTAVO = Decimal("0.01")


def quantize_money(amount: Decimal) -> Decimal:
    return amount.quantize(CENTAVO, rounding=ROUND_HALF_UP)


def calculate_item_subtotal(quantity: int, unit_price: Decimal) -> Decimal:
    if quantity <= 0:
        raise ValueError("La cantidad debe ser mayor que cero.")
    if unit_price < 0:
        raise ValueError("El precio unitario no puede ser negativo.")

    return quantize_money(Decimal(quantity) * quantize_money(unit_price))


def calculate_quote_subtotal(item_subtotals: Iterable[Decimal]) -> Decimal:
    return quantize_money(sum(item_subtotals, start=Decimal("0")))


def calculate_final_total(subtotal: Decimal, discount: Decimal) -> Decimal:
    subtotal = quantize_money(subtotal)
    discount = quantize_money(discount)

    if discount < 0:
        raise ValueError("El descuento no puede ser negativo.")
    if discount > subtotal:
        raise ValueError("El descuento no puede superar el subtotal.")

    return quantize_money(subtotal - discount)


def format_ars(amount: Decimal) -> str:
    amount = quantize_money(amount)
    sign = "− " if amount < 0 else ""
    absolute_amount = abs(amount)
    pesos = int(absolute_amount)
    centavos = int((absolute_amount - Decimal(pesos)) * 100)
    grouped_pesos = f"{pesos:,}".replace(",", ".")
    return f"{sign}$ {grouped_pesos},{centavos:02d}"
