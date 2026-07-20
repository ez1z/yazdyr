import 'package:flutter/material.dart';

import '../ledger.dart';
import '../models.dart';
import '../widgets.dart';
import 'add_credit.dart' show amountField, labeledField, dateField;

// Edit an existing transaction (credit or payment) belonging to [customerId].
class TxnFormScreen extends StatefulWidget {
  final String customerId;
  final Txn txn;
  const TxnFormScreen(
      {super.key, required this.customerId, required this.txn});

  @override
  State<TxnFormScreen> createState() => _TxnFormScreenState();
}

class _TxnFormScreenState extends State<TxnFormScreen> {
  late final TextEditingController _amount = TextEditingController(
      text: widget.txn.amount.toString().replaceFirst(RegExp(r'\.0$'), ''));
  late final TextEditingController _label =
      TextEditingController(text: widget.txn.label);
  late String _type = widget.txn.type;
  late DateTime _date = DateTime.parse('${widget.txn.date}T00:00:00');

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _label.dispose();
    super.dispose();
  }

  double? get _parsed => double.tryParse(_amount.text.trim());
  bool get _canSave => (_parsed ?? 0) > 0;

  Future<void> _save() async {
    final l = LedgerScope.read(context);
    if (!_canSave) return;
    await l.editTxn(widget.customerId, widget.txn.id,
        type: _type,
        amount: _parsed!,
        label: _label.text.trim(),
        date:
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}');
    if (!mounted) return;
    Navigator.of(context).pop();
    showToast(context, l.t('toastTransactionUpdated'));
  }

  Future<void> _confirmDelete(BuildContext context, Ledger l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('deleteTransaction')),
        content: Text(l.t('deleteTransactionConfirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.t('cancel'))),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.t('delete'))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await l.deleteTxn(widget.customerId, widget.txn.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showToast(context, l.t('toastTransactionDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('editTransaction'),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.t('deleteTransaction'),
            onPressed: () => _confirmDelete(context, l),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(l.t('type'),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.75))),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'credit', label: Text(l.t('typeCredit'))),
              ButtonSegment(value: 'payment', label: Text(l.t('typePayment'))),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 14),
          amountField(context, l.t('amountTmt'), _amount),
          labeledField(context, l.t('description'), _label,
              hint: l.t('hintCreditDesc')),
          dateField(context, l.t('date'), _date, (d) => setState(() => _date = d)),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: _canSave ? _save : null,
              child: Text(l.t('saveChanges'))),
        ],
      ),
    );
  }
}
