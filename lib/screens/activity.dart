import 'package:flutter/material.dart';

import '../format.dart';
import '../widgets.dart';
import 'txn_form.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final items = l.activityList;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
      children: [
        Text(l.t('navActivity'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),

        // Period
        _seg(context,
            segments: {
              'today': l.t('periodToday'),
              'week': l.t('periodWeek'),
              'month': l.t('periodMonth'),
              'custom': l.t('periodCustom'),
            },
            selected: l.activityFilter,
            onChanged: l.setActivityFilter),
        const SizedBox(height: 10),

        // Type + sort
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _seg(context,
                segments: {
                  'all': l.t('typeAll'),
                  'credit': l.t('typeCredit'),
                  'payment': l.t('typePayment')
                },
                selected: l.activityTypeFilter,
                onChanged: l.setActivityType),
            _seg(context,
                segments: {'newest': l.t('sortNewest'), 'amount': l.t('sortAmount')},
                selected: l.activitySort,
                onChanged: l.setActivitySort),
          ],
        ),

        if (l.activityFilter == 'custom') ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _customDate(context, l.customStartDate, l.t('dateFrom'),
                    l.setCustomStart)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(l.t('dateSep'))),
            Expanded(
                child: _customDate(
                    context, l.customEndDate, l.t('dateTo'), l.setCustomEnd)),
          ]),
        ],
        const SizedBox(height: 10),

        for (final a in items)
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor))),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TxnFormScreen(
                      customerId: a.customerId, txn: a.txn))),
              child: txRow(context,
                  title: a.customerName,
                  subtitle: '${shortDate(a.txn.date)} · ${a.txn.label}',
                  amount: money(a.txn.amount),
                  isCredit: a.txn.isCredit,
                  boldTitle: true),
            ),
          ),
      ],
    );
  }

  Widget _seg(BuildContext context,
      {required Map<String, String> segments,
      required String selected,
      required ValueChanged<String> onChanged}) {
    return SegmentedButton<String>(
      segments: [
        for (final e in segments.entries)
          ButtonSegment(value: e.key, label: Text(e.value)),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 10.5))),
    );
  }

  Widget _customDate(BuildContext context, String value, String hint,
      ValueChanged<String> onPick) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              value.isEmpty ? DateTime.now() : DateTime.parse(value),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onPick(
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(isDense: true),
        child: Text(value.isEmpty ? hint : shortDate(value),
            style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
