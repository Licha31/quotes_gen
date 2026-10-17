/// The validated quote is the single source of amounts for preview and PDF.
class Ars {
  static final _number = RegExp(
    r'^(?:\d+|\d+[.,]\d{1,2}|\d{1,3}(?:\.\d{3})+(?:,\d{1,2})?)$',
  );
  static final _grouped = RegExp(r'^\d{1,3}(?:\.\d{3})+$');

  static BigInt? tryParse(String raw) {
    var value = raw.trim().replaceAll(r'$', '').replaceAll(' ', '');
    var negative = false;
    if (value.startsWith('-')) {
      negative = true;
      value = value.substring(1);
    }
    if (!_number.hasMatch(value)) return null;
    if (value.contains(',') || _grouped.hasMatch(value)) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    }
    final parts = value.split('.');
    final whole = BigInt.parse(parts[0]);
    final cents = parts.length == 1
        ? BigInt.zero
        : BigInt.parse(parts[1].padRight(2, '0'));
    final result = whole * BigInt.from(100) + cents;
    return negative ? -result : result;
  }

  static String format(BigInt amount) {
    final negative = amount.isNegative;
    final absolute = amount.abs();
    final pesos = (absolute ~/ BigInt.from(100)).toString();
    final grouped = pesos.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final cents = (absolute % BigInt.from(100)).toString().padLeft(2, '0');
    return '${negative ? '− ' : ''}\$ $grouped,$cents';
  }
}

class QuoteItemInput {
  const QuoteItemInput(this.description, this.quantity, this.unitPrice);
  final String description;
  final String quantity;
  final String unitPrice;
}

class QuoteInput {
  const QuoteInput({
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.quoteDate,
    required this.validUntil,
    required this.items,
    required this.discount,
    required this.notes,
  });
  final String number;
  final String customerName;
  final String customerPhone;
  final String quoteDate;
  final String validUntil;
  final List<QuoteItemInput> items;
  final String discount;
  final String notes;
}

class QuoteItem {
  const QuoteItem(this.description, this.quantity, this.unitPriceCentavos);
  final String description;
  final BigInt quantity;
  final BigInt unitPriceCentavos;
  BigInt get subtotalCentavos => quantity * unitPriceCentavos;
}

class Quote {
  const Quote({
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.quoteDate,
    required this.validUntil,
    required this.items,
    required this.discountCentavos,
    required this.notes,
  });
  final String? number;
  final String customerName;
  final String? customerPhone;
  final DateTime quoteDate;
  final DateTime validUntil;
  final List<QuoteItem> items;
  final BigInt discountCentavos;
  final String? notes;

  BigInt get subtotalCentavos =>
      items.fold(BigInt.zero, (sum, item) => sum + item.subtotalCentavos);
  BigInt get totalCentavos => subtotalCentavos - discountCentavos;
}

class QuoteValidation {
  const QuoteValidation(this.quote, this.errors);
  final Quote? quote;
  final Map<String, String> errors;
  bool get isValid => quote != null;
}

String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

DateTime? _date(String raw) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw.trim());
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  if (year < 1 ||
      year > 9999 ||
      month < 1 ||
      month > 12 ||
      day < 1 ||
      day > 31) {
    return null;
  }
  final result = DateTime(year, month, day);
  return result.year == year && result.month == month && result.day == day
      ? result
      : null;
}

QuoteValidation validateQuote(QuoteInput input) {
  final errors = <String, String>{};
  final number = input.number.trim();
  if (number.length > 32) errors['number'] = 'Usá como máximo 32 caracteres.';
  final name = input.customerName.trim();
  if (name.isEmpty) errors['customerName'] = 'Este campo es obligatorio.';
  final quoteDate = _date(input.quoteDate);
  final validUntil = _date(input.validUntil);
  if (quoteDate == null) errors['quoteDate'] = 'Ingresá una fecha válida.';
  if (validUntil == null) errors['validUntil'] = 'Ingresá una fecha válida.';
  if (quoteDate != null &&
      validUntil != null &&
      validUntil.isBefore(quoteDate)) {
    errors['validUntil'] =
        'La fecha de validez no puede ser anterior a la fecha.';
  }

  final items = <QuoteItem>[];
  if (input.items.isEmpty) errors['items'] = 'Agregá al menos un producto.';
  for (var i = 0; i < input.items.length; i++) {
    final raw = input.items[i];
    final description = raw.description.trim();
    if (description.isEmpty) {
      errors['items.$i.description'] = 'Este campo es obligatorio.';
    }
    final quantityText = raw.quantity.trim();
    final quantity = RegExp(r'^-?\d+$').hasMatch(quantityText)
        ? BigInt.tryParse(quantityText)
        : null;
    if (quantity == null) {
      errors['items.$i.quantity'] = 'Ingresá un número entero.';
    } else if (quantity <= BigInt.zero) {
      errors['items.$i.quantity'] = 'Debe ser mayor que cero.';
    }
    final price = Ars.tryParse(raw.unitPrice);
    if (price == null) {
      errors['items.$i.unitPrice'] = 'Ingresá un importe válido.';
    } else if (price.isNegative) {
      errors['items.$i.unitPrice'] = 'No puede ser negativo.';
    }
    if (description.isNotEmpty &&
        quantity != null &&
        quantity > BigInt.zero &&
        price != null &&
        !price.isNegative) {
      items.add(QuoteItem(description, quantity, price));
    }
  }

  final discount = input.discount.trim().isEmpty
      ? BigInt.zero
      : Ars.tryParse(input.discount);
  if (discount == null) {
    errors['discount'] = 'Ingresá un importe válido.';
  } else if (discount.isNegative) {
    errors['discount'] = 'No puede ser negativo.';
  } else if (items.length == input.items.length &&
      discount >
          items.fold(
            BigInt.zero,
            (BigInt sum, QuoteItem item) => sum + item.subtotalCentavos,
          )) {
    errors['discount'] = 'El descuento no puede superar el subtotal.';
  }
  if (errors.isNotEmpty) return QuoteValidation(null, errors);
  return QuoteValidation(
    Quote(
      number: number.isEmpty ? null : number,
      customerName: name,
      customerPhone: input.customerPhone.trim().isEmpty
          ? null
          : input.customerPhone.trim(),
      quoteDate: quoteDate!,
      validUntil: validUntil!,
      items: List.unmodifiable(items),
      discountCentavos: discount!,
      notes: input.notes.trim().isEmpty ? null : input.notes.trim(),
    ),
    const {},
  );
}
