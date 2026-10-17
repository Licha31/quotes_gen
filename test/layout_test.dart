import 'package:adrytentaciones/main.dart';
import 'package:adrytentaciones/quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
          'NunitoSans',
        )..addFont(rootBundle.load('app/static/fonts/NunitoSans-Variable.ttf')))
        .load();
    await (FontLoader('DancingScript')
          ..addFont(rootBundle.load('assets/fonts/DancingScript-Variable.ttf')))
        .load();
  });
  for (final width in [320.0, 390.0]) {
    testWidgets('form remains usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const QuoteApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/form_${width.toInt()}.png'),
      );

      await tester.ensureVisible(find.text('Vista previa'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Total'), findsOneWidget);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/summary_${width.toInt()}.png'),
      );
    });

    testWidgets('preview fits ${width.toInt()} logical pixels', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final quote = validateQuote(
        const QuoteInput(
          number: '',
          customerName: 'Carolina Pérez',
          customerPhone: '264 555 0123',
          quoteDate: '2026-08-19',
          validUntil: '2026-08-26',
          items: [
            QuoteItemInput('12 donas', '12', '1.500,00'),
            QuoteItemInput('Torta personalizada 2 kg', '1', '45.000,00'),
          ],
          discount: '5.000,00',
          notes: 'Entrega por la tarde',
        ),
      ).quote!;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'NunitoSans'),
          home: QuotePreviewPage(quote),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/preview_${width.toInt()}.png'),
      );
      await tester.ensureVisible(find.text('Compartir o guardar PDF'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/preview_total_${width.toInt()}.png'),
      );
    });
  }
}
