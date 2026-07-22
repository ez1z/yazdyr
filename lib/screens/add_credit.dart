import 'package:flutter/material.dart';

import '../format.dart';
import '../widgets.dart';

class AddCreditScreen extends StatefulWidget {
  const AddCreditScreen({super.key});
  @override
  State<AddCreditScreen> createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  late DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  double? get _parsed => double.tryParse(_amount.text.trim());
  bool get _canSave => (_parsed ?? 0) > 0;

  Future<void> _save() async {
    final l = LedgerScope.read(context);
    if (!_canSave) return;
    final tx = await l.addCredit(l.selected.id,
        amount: _parsed!, desc: _desc.text, date: _isoOf(_date));
    sendActivitySms(l, tx);
    if (!mounted) return;
    Navigator.of(context).pop();
    showToast(context, l.t('toastCreditSaved'));
  }

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('addCredit'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(l.t('forCustomer').replaceFirst('{name}', l.selected.name),
              style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 14),
          amountField(context, l.t('amountTmt'), _amount),
          labeledField(context, l.t('description'), _desc,
              hint: l.t('hintCreditDesc')),
          dateField(context, l.t('date'), _date, (d) => setState(() => _date = d)),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _canSave ? _save : null,
              child: Text(l.t('saveCredit'))),
        ],
      ),
    );
  }
}

// ---- shared form field helpers (used by credit + payment) ----

String _isoOf(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Widget amountField(
    BuildContext context, String label, TextEditingController c) {
  return labeledField(context, label, c,
      hint: '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true));
}

Widget labeledField(BuildContext context, String label, TextEditingController c,
    {String? hint, TextInputType? keyboardType, int lines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: keyboardType,
          maxLines: lines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    ),
  );
}

Widget dateField(BuildContext context, String label, DateTime value,
    ValueChanged<DateTime> onPick) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75))),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) onPick(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Text(shortDate(_isoOf(value))),
          ),
        ),
      ],
    ),
  );
}
