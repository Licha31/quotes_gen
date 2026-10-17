import 'package:adrytentaciones/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> scrollIntoView(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 12; attempt++) {
    final bounds = tester.getRect(target);
    if (bounds.top >= 60 && bounds.bottom <= 590) return;
    await tester.drag(
      find.byType(ListView).first,
      Offset(0, bounds.top > 590 ? -450 : 450),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Could not scroll target into view');
}

void main() {
  testWidgets('validation keeps entry and preview uses calculated totals', (
    tester,
  ) async {
    await tester.pumpWidget(const QuoteApp());
    await tester.enterText(find.byType(TextField).at(1), 'Carolina Pérez');
    await tester.enterText(find.byType(TextField).at(3), '12 donas');
    await tester.enterText(find.byType(TextField).at(4), '0');
    await tester.enterText(find.byType(TextField).at(5), '1.500,00');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await scrollIntoView(tester, find.text('Vista previa'));
    await tester.tap(find.text('Vista previa'));
    await tester.pumpAndSettle();

    expect(find.text('Debe ser mayor que cero.'), findsOneWidget);
    expect(
      (tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text),
      'Carolina Pérez',
    );
    expect(
      (tester.widget<TextField>(find.byType(TextField).at(4)).controller!.text),
      '0',
    );

    await tester.enterText(find.byType(TextField).at(4), '12');
    await tester.enterText(find.byType(TextField).at(6), '5.000');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await scrollIntoView(tester, find.text('Vista previa'));
    await tester.tap(find.text('Vista previa'));
    await tester.pumpAndSettle();

    expect(find.text('Presupuesto para Carolina Pérez'), findsOneWidget);
    expect(find.text(r'$ 18.000,00'), findsWidgets);
    expect(find.text('− \$ 5.000,00'), findsOneWidget);
    expect(find.text(r'$ 13.000,00'), findsOneWidget);
  });

  testWidgets('new product starts at one; last product remains', (
    tester,
  ) async {
    await tester.pumpWidget(const QuoteApp());
    await scrollIntoView(tester, find.text('Agregar otro producto'));
    await tester.tap(find.text('Agregar otro producto'));
    await tester.pumpAndSettle();
    expect(find.text('Producto 2'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == '1',
      ),
      findsNWidgets(2),
    );

    await scrollIntoView(tester, find.text('Producto 2'));
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();
    expect(find.text('Producto 2'), findsNothing);
    expect(find.text('Eliminar'), findsNothing);
  });

  testWidgets('a fresh launch has no saved draft', (tester) async {
    await tester.pumpWidget(const QuoteApp());
    await tester.enterText(find.byType(TextField).at(1), 'Carolina Pérez');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const QuoteApp());
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      isEmpty,
    );
  });
}
