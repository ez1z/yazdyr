import 'package:flutter/material.dart';

import '../widgets.dart';
import 'add_credit.dart' show amountField, labeledField, dateField;

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});
  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  late DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  double? get _parsed => double.tryParse(_amount.text.trim());
  bool get _canSave => (_parsed ?? 0) > 0;

  Future<void> _save() async {
    final l = LedgerScope.read(context);
    if (!_canSave) return;
    await l.recordPayment(l.selected.id,
        amount: _parsed!,
        notes: _notes.text,
        date:
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}');
    if (!mounted) return;
    Navigator.of(context).pop();
    showToast(context, 'Payment recorded');
  }

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('Record Payment',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('For ${l.selected.name}',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 14),
          amountField(context, 'Amount (TMT) *', _amount),
          dateField(context, 'Date', _date, (d) => setState(() => _date = d)),
          labeledField(context, 'Notes', _notes,
              hint: 'Optional notes', lines: 3),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Save Payment')),
        ],
      ),
    );
  }
}
