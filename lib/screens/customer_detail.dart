import 'package:flutter/material.dart';

import '../format.dart';
import '../ledger.dart';
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
                    title: localDateTime(t.createdAt, l.language),
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
