import 'package:flutter/material.dart';

import '../format.dart';
import '../ledger.dart';
import '../models.dart';
import '../widgets.dart';
import 'add_credit.dart';
import 'customer_form.dart';
import 'record_payment.dart';
import 'txn_form.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final c = l.selected;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.name,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
            Text(c.phone.isEmpty ? '—' : c.phone,
                style: TextStyle(
                    fontSize: 12, color: onSurface.withValues(alpha: 0.6))),
          ],
        ),
        actions: [
          if (c.phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sms_outlined),
              tooltip: l.t('sendSms'),
              onPressed: () => _onSmsPressed(context, l, c),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.t('deleteCustomer'),
            onPressed: () => _confirmDelete(context, l, c.id, c.name),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Balance
          Center(
            child: Column(
              children: [
                Text(l.t('currentBalance'),
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: onSurface.withValues(alpha: 0.55))),
                const SizedBox(height: 4),
                Text(money(c.balance),
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddCreditScreen())),
                icon: const Icon(Icons.add, size: 16),
                label: Text(l.t('addCredit')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const RecordPaymentScreen())),
                icon: const Icon(Icons.payments_outlined, size: 16),
                label: Text(l.t('recordPayment')),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CustomerFormScreen(editId: c.id))),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: Text(l.t('editCustomer')),
          ),
          Divider(height: 32, color: Theme.of(context).dividerColor),

          sectionHeader(context, l.t('transactionHistory')),
          for (final t in c.transactions)
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Theme.of(context).dividerColor))),
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        TxnFormScreen(customerId: c.id, txn: t))),
                child: txRow(context,
                    title: shortDate(t.date),
                    subtitle: t.label,
                    amount: money(t.amount),
                    isCredit: t.isCredit),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Ledger l, String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('deleteCustomer')),
        content: Text(l.t('deleteCustomerConfirm').replaceFirst('{name}', name)),
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
    await l.deleteCustomer(id);
    if (!context.mounted) return;
    Navigator.of(context).pop(); // back to customers list
    showToast(context, l.t('toastCustomerDeleted'));
  }
}

// Auto-send on: compose the full ledger message and fire it silently, no popup.
// Off: open the compose sheet (review/edit, then the messaging app).
Future<void> _onSmsPressed(BuildContext context, Ledger l, Customer c) async {
  if (!l.autoSendSms) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SmsSheet(customer: c, l: l),
    );
    return;
  }
  final body = _composeSms(l, c, balance: true, transactions: true);
  final sent = await sendSmsAuto(c.phone, body);
  if (!context.mounted) return;
  if (sent) {
    showToast(context, l.t('toastSmsSent'));
  } else {
    // Not sent (permission just requested / non-Android) — fall back this once.
    sendSms(c.phone, body);
  }
}

// Builds the SMS body from the selected sections. The composer is also editable,
// so this is just a sensible starting point.
String _composeSms(Ledger l, Customer c,
    {required bool balance, required bool transactions}) {
  final lines = <String>['${l.t('smsGreeting')} ${c.name}'];
  if (balance) lines.add('${l.t('smsBalanceLabel')}: ${money(c.balance)}');
  if (transactions && c.transactions.isNotEmpty) {
    lines.add('');
    for (final t in c.transactions) {
      final amount = '${t.isCredit ? '+' : '-'}${money(t.amount)}';
      final label = t.label.isNotEmpty
          ? '  (${t.label})'
          : (t.isPayment ? '  (${l.t('smsPaymentWord')})' : '');
      lines.add('${shortDate(t.date)}  $amount$label');
    }
  }
  return lines.join('\n');
}

// Bottom sheet: pick what to include, tweak the text, then send.
class _SmsSheet extends StatefulWidget {
  const _SmsSheet({required this.customer, required this.l});
  final Customer customer;
  final Ledger l;

  @override
  State<_SmsSheet> createState() => _SmsSheetState();
}

class _SmsSheetState extends State<_SmsSheet> {
  bool _balance = true;
  bool _transactions = true;
  late final TextEditingController _controller =
      TextEditingController(text: _compose());

  String _compose() => _composeSms(widget.l, widget.customer,
      balance: _balance, transactions: _transactions);

  void _regenerate() => _controller.text = _compose();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.t('sendSms'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l.t('smsIncludeBalance')),
            value: _balance,
            onChanged: (v) => setState(() {
              _balance = v;
              _regenerate();
            }),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l.t('smsIncludeTransactions')),
            value: _transactions,
            onChanged: (v) => setState(() {
              _transactions = v;
              _regenerate();
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 6,
            minLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              sendSms(widget.customer.phone, _controller.text);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.send, size: 16),
            label: Text(l.t('send')),
          ),
        ],
      ),
    );
  }
}
