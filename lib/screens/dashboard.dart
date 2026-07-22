import 'package:flutter/material.dart';

import '../format.dart';
import '../widgets.dart';
import 'customer_form.dart';
import 'home.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final highestDebt = l.highestDebtList;
    final overdue = l.overdueList;
    final recent = l.recentActivity;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const Text('Ýazdyr',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(l.t('tagline'),
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 18),

        // Stat cards
        Row(children: [
          Expanded(
              child: statCard(context,
                  kicker: l.t('statTotalCustomers'),
                  value: '${l.totalCustomers}',
                  valueSize: 28)),
          const SizedBox(width: 10),
          Expanded(
              child: statCard(context,
                  kicker: l.t('statOutstandingDebt'),
                  value: money(l.totalOutstanding),
                  accent: true,
                  valueSize: 22)),
        ]),
        const SizedBox(height: 10),
        statCard(context,
            kicker: l.t('statTodayCredit'),
            value: money(l.todayCredit),
            valueSize: 24),
        const SizedBox(height: 22),

        // Quick actions
        sectionHeader(context, l.t('quickActions')),
        Row(children: [
          _quickAction(context, Icons.add, l.t('addCustomer'), () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CustomerFormScreen()));
          }),
          const SizedBox(width: 8),
          _quickAction(context, Icons.credit_card, l.t('newCredit'), () {
            switchToTab(context, 1);
            showToast(context, l.t('selectCustomerCredit'));
          }),
          const SizedBox(width: 8),
          _quickAction(context, Icons.payments_outlined, l.t('recordPayment'), () {
            switchToTab(context, 1);
            showToast(context, l.t('selectCustomerPayment'));
          }),
        ]),
        const SizedBox(height: 26),

        // Highest debt — top 3
        sectionHeader(context, l.t('highestDebt')),
        boxList(context, [
          if (highestDebt.isEmpty)
            _emptyRow(context, l.t('noDebts'))
          else
            for (final d in highestDebt)
              _divRow(context,
                  title: d.name, subtitle: d.subLabel, amount: money(d.balance)),
        ]),
        const SizedBox(height: 26),

        // Longest without payment
        sectionHeader(context, l.t('longestWithoutPayment')),
        boxList(context, [
          for (final o in overdue)
            _divRow(context,
                title: o.name, subtitle: o.subLabel, amount: money(o.balance)),
        ]),
        const SizedBox(height: 26),

        // Recent activity
        sectionHeader(context, l.t('recentActivity'),
            trailing: GestureDetector(
                onTap: () => switchToTab(context, 2),
                child: Text(l.t('seeAll'),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary)))),
        boxList(context, [
          for (final a in recent)
            txRow(context,
                title: a.customerName,
                subtitle:
                    '${localDateTime(a.txn.createdAt, l.language)} · ${a.txn.label}',
                amount: money(a.txn.amount),
                isCredit: a.txn.isCredit),
        ]),
      ],
    );
  }

  Widget _quickAction(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 84,
        child: FilledButton.tonal(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
    );
  }

  Widget _divRow(BuildContext context,
      {required String title,
      required String subtitle,
      required String amount}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: onSurface.withValues(alpha: 0.55))),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
