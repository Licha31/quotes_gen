import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:adrytentaciones/quote.dart';
import 'package:adrytentaciones/quote_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Quote quote({String number = ''}) => validateQuote(
    QuoteInput(
      number: number,
      customerName: 'Carolina Pérez',
      customerPhone: '',
      quoteDate: '2026-08-19',
      validUntil: '2026-08-26',
      items: List.generate(
        45,
        (index) => QuoteItemInput(
          'Torta personalizada de chocolate y vainilla número $index con decoración artesanal y mensaje para la celebración',
          '1',
          '45.000,50',
        ),
      ),
      discount: '5.000',
      notes: List.filled(
        8,
        'Entrega por la tarde. Decoración a confirmar con la clienta.',
      ).join('\n'),
    ),
  ).quote!;

  test('normalizes accented customer filename and supplied number', () {
    expect(pdfFilename(quote()), 'presupuesto-carolina-perez.pdf');
    expect(pdfFilename(quote(number: ' ADRY/32 ')), 'presupuesto-adry-32.pdf');
  });

  test('generates a valid multipage PDF with long content', () async {
    final bytes = await buildQuotePdf(quote());
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });

  test('wraps an exceptionally long description and notes', () async {
    final longQuote = validateQuote(
      QuoteInput(
        number: '',
        customerName: 'Carolina Pérez',
        customerPhone: '',
        quoteDate: '2026-08-19',
        validUntil: '2026-08-26',
        items: [
          QuoteItemInput(
            List.filled(70, 'Decoración artesanal de vainilla').join(' '),
            '1',
            '100',
          ),
        ],
        discount: '0',
        notes: List.filled(70, 'Entrega coordinada con la clienta.').join('\n'),
      ),
    ).quote!;
    final bytes = await buildQuotePdf(longQuote);
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  });
}
