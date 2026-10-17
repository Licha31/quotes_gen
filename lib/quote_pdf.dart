import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'quote.dart';

const _coral = PdfColor.fromInt(0xFFE96F61);
const _coralDeep = PdfColor.fromInt(0xFFBD4E45);
const _cocoa = PdfColor.fromInt(0xFF342824);
const _soft = PdfColor.fromInt(0xFF6F5D57);
const _rule = PdfColor.fromInt(0xFFE0D5CF);

List<String> _textChunks(String text, int limit) {
  final chunks = <String>[];
  var remaining = text;
  while (remaining.length > limit) {
    var cut = remaining.lastIndexOf('\n', limit);
    if (cut < limit ~/ 3) cut = remaining.lastIndexOf(' ', limit);
    if (cut < limit ~/ 3) cut = limit;
    chunks.add(remaining.substring(0, cut));
    remaining = remaining.substring(cut).trimLeft();
  }
  chunks.add(remaining);
  return chunks;
}

String pdfFilename(Quote quote) {
  final source = quote.number ?? quote.customerName;
  const accents = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'Á': 'A',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'É': 'E',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'Í': 'I',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'Ó': 'O',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'Ú': 'U',
    'ñ': 'n',
    'Ñ': 'N',
  };
  final normalized = source
      .split('')
      .map((character) => accents[character] ?? character)
      .join();
  var safe = normalized
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '')
      .toLowerCase();
  if (safe.length > 60) {
    safe = safe.substring(0, 60).replaceAll(RegExp(r'-+$'), '');
  }
  return 'presupuesto-${safe.isEmpty ? 'cliente' : safe}.pdf';
}

Future<Uint8List> buildQuotePdf(Quote quote) async {
  final regularFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NunitoSans-500.ttf'),
  );
  final boldFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NunitoSans-700.ttf'),
  );
  final heavyFont = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NunitoSans-800.ttf'),
  );
  final scriptBytes = await rootBundle.load(
    'assets/fonts/DancingScript-Variable.ttf',
  );
  final script = pw.Font.ttf(scriptBytes);
  final regular = pw.TextStyle(
    font: regularFont,
    fontSize: 10.5,
    color: _cocoa,
  );
  final bold = pw.TextStyle(font: boldFont, fontSize: 10.5, color: _cocoa);
  final heavy = pw.TextStyle(font: heavyFont, fontSize: 10.5, color: _cocoa);
  final document = pw.Document(title: 'Presupuesto de Adrytentaciones');
  final noteChunks = quote.notes == null
      ? <String>[]
      : _textChunks(quote.notes!, 800);

  pw.Widget labelValue(String label, String value) => pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _rule)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: regular.copyWith(color: _soft, fontSize: 9)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: bold),
      ],
    ),
  );

  pw.Widget totalRow(String label, String value, {bool emphasized = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: emphasized ? bold : regular.copyWith(color: _soft),
            ),
            pw.Text(
              value,
              style: (emphasized ? heavy : bold).copyWith(
                fontSize: emphasized ? 18 : 10.5,
                color: emphasized ? _coralDeep : _cocoa,
              ),
            ),
          ],
        ),
      );

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 46),
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
      build: (_) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Adrytentaciones',
                  style: pw.TextStyle(
                    font: script,
                    fontSize: 30,
                    color: _coralDeep,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Pastelería artesanal',
                  style: regular.copyWith(color: _soft, fontSize: 9),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Adrytentaciones', style: bold.copyWith(fontSize: 9)),
                pw.Text(
                  'Pastelería artesanal',
                  style: regular.copyWith(fontSize: 9, color: _soft),
                ),
                pw.Text(
                  'San Juan, Argentina',
                  style: regular.copyWith(fontSize: 9, color: _soft),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 25),
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 16),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _coral, width: 3)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Presupuesto', style: bold.copyWith(fontSize: 22)),
                    pw.Text(
                      'Preparado especialmente para ${quote.customerName}.',
                      style: regular.copyWith(color: _soft),
                    ),
                  ],
                ),
              ),
              if (quote.number != null)
                pw.Text(
                  'Número  ${quote.number}',
                  style: bold.copyWith(color: _coralDeep),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        pw.Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            pw.SizedBox(
              width: 112,
              child: labelValue('Cliente', quote.customerName),
            ),
            if (quote.customerPhone != null)
              pw.SizedBox(
                width: 112,
                child: labelValue('Teléfono', quote.customerPhone!),
              ),
            pw.SizedBox(
              width: 112,
              child: labelValue('Fecha', dateLabel(quote.quoteDate)),
            ),
            pw.SizedBox(
              width: 112,
              child: labelValue('Válido hasta', dateLabel(quote.validUntil)),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Text('Detalle del pedido', style: bold.copyWith(fontSize: 13.5)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Descripción', 'Cantidad', 'Precio unitario', 'Subtotal'],
          data: [
            for (final item in quote.items)
              for (final (index, description) in _textChunks(
                item.description,
                300,
              ).indexed)
                [
                  description,
                  index == 0 ? item.quantity.toString() : '',
                  index == 0 ? Ars.format(item.unitPriceCentavos) : '',
                  index == 0 ? Ars.format(item.subtotalCentavos) : '',
                ],
          ],
          columnWidths: {
            0: const pw.FlexColumnWidth(2.5),
            1: const pw.FlexColumnWidth(.65),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
          },
          cellStyle: regular,
          headerStyle: bold.copyWith(color: _soft, fontSize: 9),
          cellAlignment: pw.Alignment.topRight,
          headerAlignment: pw.Alignment.centerRight,
          cellAlignments: {0: pw.Alignment.topLeft},
          headerAlignments: {0: pw.Alignment.centerLeft},
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 9,
          ),
          headerDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _rule)),
          ),
          border: pw.TableBorder(
            horizontalInside: const pw.BorderSide(color: _rule),
            bottom: const pw.BorderSide(color: _rule),
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 235,
            padding: const pw.EdgeInsets.fromLTRB(12, 12, 12, 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _coral, width: 3)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Resumen', style: bold.copyWith(fontSize: 13.5)),
                pw.Divider(color: _rule),
                totalRow('Subtotal', Ars.format(quote.subtotalCentavos)),
                if (quote.discountCentavos > BigInt.zero)
                  totalRow(
                    'Descuento',
                    '- ${Ars.format(quote.discountCentavos)}',
                  ),
                pw.Divider(color: _rule),
                totalRow(
                  'Total',
                  Ars.format(quote.totalCentavos),
                  emphasized: true,
                ),
              ],
            ),
          ),
        ),
        if (noteChunks.isNotEmpty) ...[
          pw.SizedBox(height: 24),
          pw.Inseparable(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Divider(color: _rule),
                pw.Text('Notas', style: bold.copyWith(fontSize: 13.5)),
                pw.SizedBox(height: 8),
                pw.Text(noteChunks.first, style: regular),
              ],
            ),
          ),
          for (final chunk in noteChunks.skip(1))
            pw.Text(chunk, style: regular),
        ],
        pw.SizedBox(height: 28),
        pw.Divider(color: _coral),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Gracias por elegir Adrytentaciones.',
              style: regular.copyWith(fontSize: 9, color: _soft),
            ),
            pw.Text(
              'Pastelería artesanal · San Juan, Argentina',
              style: regular.copyWith(fontSize: 9, color: _soft),
            ),
          ],
        ),
      ],
    ),
  );
  return document.save();
}
