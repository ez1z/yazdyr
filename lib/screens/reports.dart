import 'package:flutter/material.dart';

import '../format.dart';
import '../widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('reports'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          statCard(context,
              kicker: l.t('totalCreditGiven'),
              value: money(l.totalCreditGiven)),
          const SizedBox(height: 10),
          statCard(context,
              kicker: l.t('totalPaymentsReceived'),
              value: money(l.totalPaymentsReceived)),
          const SizedBox(height: 10),
          statCard(context,
              kicker: l.t('outstandingBalance'),
              value: money(l.totalOutstanding),
              accent: true),
        ],
      ),
    );
  }
}
