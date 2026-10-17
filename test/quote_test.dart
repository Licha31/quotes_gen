import 'package:flutter_test/flutter_test.dart';
import 'package:adrytentaciones/quote.dart';

QuoteInput validInput({
  String number = '  ADRY-32  ',
  String name = 'Carolina Pérez',
  String date = '2026-08-19',
  String until = '2026-08-26',
  List<QuoteItemInput>? items,
  String discount = '5.000,00',
}) => QuoteInput(
  number: number,
  customerName: name,
  customerPhone: '',
  quoteDate: date,
  validUntil: until,
  items:
      items ??
      const [
        QuoteItemInput('12 donas', '12', '1.500,00'),
        QuoteItemInput('Torta personalizada 2 kg', '1', '45.000,00'),
      ],
  discount: discount,
  notes: '',
);

void main() {
  test('parses and formats Argentine pesos using integer centavos', () {
    for (final input in ['45000', '45.000']) {
      expect(Ars.tryParse(input), BigInt.from(4500000));
    }
    for (final input in ['45000,50', '45000.50', '45.000,50']) {
      expect(Ars.tryParse(input), BigInt.from(4500050));
    }
    expect(Ars.format(BigInt.from(4500050)), r'$ 45.000,50');
    expect(Ars.tryParse('1.2.3'), isNull);
    expect(Ars.tryParse('1..2,50'), isNull);
  });

  test('calculates item, quote, discount and final totals', () {
    final quote = validateQuote(validInput()).quote!;
    expect(quote.number, 'ADRY-32');
    expect(quote.items[0].subtotalCentavos, BigInt.from(1800000));
    expect(quote.items[1].subtotalCentavos, BigInt.from(4500000));
    expect(Ars.format(quote.subtotalCentavos), r'$ 63.000,00');
    expect(Ars.format(quote.totalCentavos), r'$ 58.000,00');
  });

  test('optional number is absent and length is limited', () {
    expect(validateQuote(validInput(number: '  ')).quote!.number, isNull);
    expect(
      validateQuote(validInput(number: List.filled(33, 'A').join()))
          .errors['number'],
      isNotNull,
    );
  });

  test('validates dates, required fields, quantities and money', () {
    expect(
      validateQuote(validInput(name: ' ')).errors['customerName'],
      isNotNull,
    );
    expect(
      validateQuote(validInput(until: '2026-08-18')).errors['validUntil'],
      isNotNull,
    );
    expect(
      validateQuote(validInput(date: '2026-02-30')).errors['quoteDate'],
      isNotNull,
    );
    for (final quantity in ['0', '-1', '1.5']) {
      expect(
        validateQuote(
          validInput(items: [QuoteItemInput('Torta', quantity, '100')]),
        ).errors['items.0.quantity'],
        isNotNull,
      );
    }
    expect(
      validateQuote(validInput(items: const [QuoteItemInput('', '1', '100')]))
          .errors['items.0.description'],
      isNotNull,
    );
    expect(
      validateQuote(
        validInput(items: const [QuoteItemInput('Torta', '1', '-100')]),
      ).errors['items.0.unitPrice'],
      isNotNull,
    );
    expect(
      validateQuote(validInput(discount: '-1')).errors['discount'],
      isNotNull,
    );
    expect(
      validateQuote(validInput(discount: '63.000,01')).errors['discount'],
      isNotNull,
    );
    expect(
      validateQuote(validInput(items: const [])).errors['items'],
      isNotNull,
    );
  });
}
