import 'package:flutter/material.dart';

import '../format.dart';
import '../models.dart';
import '../widgets.dart';
import 'customer_detail.dart';
import 'customer_form.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final list = l.customersView;
    final showEmpty = l.showEmptyDemo;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CustomerFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
        children: [
          Text(l.t('navCustomers'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          // Search
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.t('searchHint'),
              isDense: true,
            ),
            onChanged: l.setSearchQuery,
          ),
          const SizedBox(height: 16),

          // Sort
          SegmentedButton<String>(
            segments: [
              const ButtonSegment(value: 'alpha', label: Text('A–Z')),
              ButtonSegment(value: 'debt', label: Text(l.t('sortHighestDebt'))),
              ButtonSegment(value: 'recent', label: Text(l.t('sortRecent'))),
            ],
            selected: {l.sortMode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => l.setSortMode(s.first),
            style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11.5))),
          ),
          const SizedBox(height: 16),

          if (showEmpty || list.isEmpty)
            _emptyState(context)
          else
            ...list.map((c) => _customerTile(context, c)),

          // Preview toggle only makes sense once real customers exist.
          if (list.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: l.toggleEmptyDemo,
                child: Text(
                    showEmpty ? l.t('showSampleCustomers') : l.t('previewEmpty'),
                    style: TextStyle(
                        fontSize: 11, color: onSurface.withValues(alpha: 0.55))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _customerTile(BuildContext context, Customer c) {
    final l = LedgerScope.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          l.select(c.id);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomerDetailScreen()));
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                        '${c.phone.isEmpty ? '—' : c.phone} · ${shortDate(c.lastDate)}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Text(money(c.balance),
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final l = LedgerScope.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 40, color: onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(l.t('noCustomers'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l.t('addFirstCustomer'),
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerFormScreen())),
            child: Text(l.t('addCustomer')),
          ),
        ],
      ),
    );
  }
}
