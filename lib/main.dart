import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:printing/printing.dart';

import 'quote.dart';
import 'quote_pdf.dart';

const cream = Color(0xFFFFFDF9);
const meringue = Color(0xFFFFFAF3);
const blush = Color(0xFFF8E9E5);
const blushSoft = Color(0xFFFCEFEB);
const coral = Color(0xFFE96F61);
const coralDeep = Color(0xFFBD4E45);
const cocoa = Color(0xFF342824);
const cocoaSoft = Color(0xFF6F5D57);
const line = Color(0x30533730);

void main() => runApp(const QuoteApp());

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Adrytentaciones',
    debugShowCheckedModeBanner: false,
    locale: const Locale('es'),
    supportedLocales: const [Locale('es')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      fontFamily: 'NunitoSans',
      scaffoldBackgroundColor: blush,
      colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coralDeep),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: cocoa),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFBF6F1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: line),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: coral, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        errorMaxLines: 3,
      ),
    ),
    home: const QuoteFormPage(),
  );
}

class _ItemFields {
  _ItemFields(void Function() changed)
    : description = TextEditingController(),
      quantity = TextEditingController(text: '1'),
      price = TextEditingController() {
    for (final controller in [description, quantity, price]) {
      controller.addListener(changed);
    }
  }
  final TextEditingController description;
  final TextEditingController quantity;
  final TextEditingController price;
  void dispose() {
    description.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class QuoteFormPage extends StatefulWidget {
  const QuoteFormPage({super.key});
  @override
  State<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends State<QuoteFormPage> {
  final number = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final discount = TextEditingController();
  final notes = TextEditingController();
  late final List<_ItemFields> items;
  late DateTime quoteDate;
  late DateTime validUntil;
  Map<String, String> errors = {};

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    quoteDate = DateUtils.dateOnly(DateTime.now());
    validUntil = quoteDate.add(const Duration(days: 7));
    items = [_ItemFields(changed)];
    for (final controller in [number, name, phone, discount, notes]) {
      controller.addListener(changed);
    }
  }

  @override
  void dispose() {
    for (final controller in [number, name, phone, discount, notes]) {
      controller.dispose();
    }
    for (final item in items) {
      item.dispose();
    }
    super.dispose();
  }

  String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  QuoteInput get input => QuoteInput(
    number: number.text,
    customerName: name.text,
    customerPhone: phone.text,
    quoteDate: iso(quoteDate),
    validUntil: iso(validUntil),
    items: [
      for (final item in items)
        QuoteItemInput(
          item.description.text,
          item.quantity.text,
          item.price.text,
        ),
    ],
    discount: discount.text,
    notes: notes.text,
  );

  BigInt itemSubtotal(_ItemFields item) {
    final quantity = BigInt.tryParse(item.quantity.text.trim());
    final price = Ars.tryParse(item.price.text);
    if (quantity == null ||
        quantity <= BigInt.zero ||
        price == null ||
        price.isNegative) {
      return BigInt.zero;
    }
    return quantity * price;
  }

  BigInt get subtotal =>
      items.fold(BigInt.zero, (sum, item) => sum + itemSubtotal(item));
  BigInt get discountAmount {
    final value = Ars.tryParse(discount.text);
    return value != null && !value.isNegative ? value : BigInt.zero;
  }

  Future<void> pickDate(bool validity) async {
    final current = validity ? validUntil : quoteDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      locale: const Locale('es'),
    );
    if (selected != null) {
      setState(() {
        if (validity) {
          validUntil = selected;
        } else {
          quoteDate = selected;
        }
        errors.remove('quoteDate');
        errors.remove('validUntil');
      });
    }
  }

  void preview() {
    final result = validateQuote(input);
    setState(() => errors = result.errors);
    if (result.quote != null) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuotePreviewPage(result.quote!),
        ),
      );
    }
  }

  Widget section(
    String index,
    String title,
    String description,
    List<Widget> children,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 38,
              child: Text(
                index,
                style: const TextStyle(
                  color: coralDeep,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: cocoa,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: cocoaSoft, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    ),
  );

  Widget field(
    String label,
    TextEditingController controller,
    String key, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cocoa,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          onChanged: (_) {
            if (errors.containsKey(key)) setState(() => errors.remove(key));
          },
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          decoration: InputDecoration(hintText: hint, errorText: errors[key]),
        ),
      ],
    ),
  );

  Widget dateField(
    String label,
    DateTime value,
    String key,
    bool validity,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        Semantics(
          label: '$label ${dateLabel(value)}',
          button: true,
          child: OutlinedButton.icon(
            onPressed: () => pickDate(validity),
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            label: Text(dateLabel(value), style: const TextStyle(fontSize: 17)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              foregroundColor: cocoa,
              backgroundColor: const Color(0xFFFBF6F1),
              side: const BorderSide(color: line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        if (errors[key] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(errors[key]!, style: const TextStyle(color: coralDeep)),
          ),
      ],
    ),
  );

  Widget product(int index) {
    final item = items[index];
    return Container(
      key: ObjectKey(item),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Producto ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (items.length > 1)
                TextButton(
                  onPressed: () => setState(() {
                    items.removeAt(index).dispose();
                    errors = {};
                  }),
                  child: const Text('Eliminar'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          field(
            'Descripción',
            item.description,
            'items.$index.description',
            hint: 'Ej. Torta personalizada 2 kg',
          ),
          field(
            'Cantidad',
            item.quantity,
            'items.$index.quantity',
            keyboardType: TextInputType.number,
          ),
          field(
            'Precio unitario · \$',
            item.price,
            'items.$index.unitPrice',
            hint: '45.000,00',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: cocoaSoft, fontWeight: FontWeight.w600),
              ),
              Text(
                Ars.format(itemSubtotal(item)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cocoa,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: meringue,
      title: const Text(
        'Adrytentaciones',
        style: TextStyle(
          fontFamily: 'DancingScript',
          color: coralDeep,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    ),
    body: SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo presupuesto',
                  style: TextStyle(
                    fontSize: 29,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: cocoa,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cargá los datos del cliente y del pedido.',
                  style: TextStyle(fontSize: 16, color: cocoaSoft),
                ),
                if (errors.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Revisá los datos del presupuesto',
                      style: TextStyle(
                        color: coralDeep,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: cream,
              border: Border(top: BorderSide(color: coral, width: 3)),
            ),
            child: Column(
              children: [
                section(
                  '01',
                  'Presupuesto y cliente',
                  'Los datos para identificar el presupuesto.',
                  [
                    field(
                      'Número de presupuesto · Opcional',
                      number,
                      'number',
                      hint: 'Ej. 2026-015',
                      maxLength: 32,
                    ),
                    field(
                      'Nombre',
                      name,
                      'customerName',
                      hint: 'Ej. Carolina Pérez',
                    ),
                    field(
                      'Teléfono · Opcional',
                      phone,
                      'customerPhone',
                      hint: 'Ej. 264 555 0123',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const Divider(height: 1, color: line),
                section(
                  '02',
                  'Fechas',
                  'Cuándo se prepara y hasta cuándo es válida.',
                  [
                    dateField('Fecha', quoteDate, 'quoteDate', false),
                    dateField('Válido hasta', validUntil, 'validUntil', true),
                  ],
                ),
                const Divider(height: 1, color: line),
                section(
                  '03',
                  'Productos o servicios',
                  'Describí cada producto como aparecerá en el presupuesto.',
                  [
                    for (var i = 0; i < items.length; i++) product(i),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => items.add(_ItemFields(changed))),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar otro producto'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: coralDeep,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1, color: line),
                section(
                  '04',
                  'Ajustes finales',
                  'Sumá un descuento fijo o una aclaración.',
                  [
                    field(
                      'Descuento · \$',
                      discount,
                      'discount',
                      hint: '0,00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                    field(
                      'Notas · Opcional',
                      notes,
                      'notes',
                      hint: 'Seña, entrega o detalles de decoración',
                      maxLines: 4,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  color: blushSoft,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      amountRow('Subtotal', Ars.format(subtotal)),
                      amountRow('Descuento', '− ${Ars.format(discountAmount)}'),
                      const Divider(color: coral),
                      amountRow(
                        'Total',
                        Ars.format(subtotal - discountAmount),
                        finalTotal: true,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: preview,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: coralDeep,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Vista previa',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    ),
  );
}

Widget amountRow(String label, String amount, {bool finalTotal = false}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: finalTotal ? 18 : 16,
              fontWeight: finalTotal ? FontWeight.w700 : FontWeight.w600,
              color: cocoa,
            ),
          ),
          Flexible(
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: finalTotal ? 25 : 17,
                fontWeight: finalTotal ? FontWeight.w800 : FontWeight.w600,
                color: finalTotal ? coralDeep : cocoa,
              ),
            ),
          ),
        ],
      ),
    );

class QuotePreviewPage extends StatelessWidget {
  const QuotePreviewPage(this.quote, {super.key});
  final Quote quote;

  Widget detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: cocoaSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: meringue,
      title: const Text(
        'Adrytentaciones',
        style: TextStyle(
          fontFamily: 'DancingScript',
          color: coralDeep,
          fontSize: 29,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: cream,
              border: Border(top: BorderSide(color: coral, width: 3)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presupuesto para ${quote.customerName}',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: cocoa,
                  ),
                ),
                const SizedBox(height: 20),
                if (quote.number != null) detail('Número', quote.number!),
                detail('Cliente', quote.customerName),
                if (quote.customerPhone != null)
                  detail('Teléfono', quote.customerPhone!),
                detail('Fecha', dateLabel(quote.quoteDate)),
                detail('Válido hasta', dateLabel(quote.validUntil)),
                const Divider(height: 38, color: line),
                const Text(
                  'Detalle del pedido',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final item in quote.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item.quantity} × ${Ars.format(item.unitPriceCentavos)}',
                          style: const TextStyle(color: cocoaSoft),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            Ars.format(item.subtotalCentavos),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Divider(color: line),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  color: blushSoft,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      amountRow('Subtotal', Ars.format(quote.subtotalCentavos)),
                      amountRow(
                        'Descuento',
                        '− ${Ars.format(quote.discountCentavos)}',
                      ),
                      const Divider(color: coral),
                      amountRow(
                        'Total',
                        Ars.format(quote.totalCentavos),
                        finalTotal: true,
                      ),
                    ],
                  ),
                ),
                if (quote.notes != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Notas',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(quote.notes!, style: const TextStyle(fontSize: 16)),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final bytes = await buildQuotePdf(quote);
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: pdfFilename(quote),
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No se pudo generar o compartir el PDF. Intentá de nuevo.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Compartir o guardar PDF'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: coralDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Editar presupuesto'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
