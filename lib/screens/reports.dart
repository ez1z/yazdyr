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
          title: const Text('Reports',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          statCard(context,
              kicker: 'Total Credit Given',
              value: money(l.totalCreditGiven)),
          const SizedBox(height: 10),
          statCard(context,
              kicker: 'Total Payments Received',
              value: money(l.totalPaymentsReceived)),
          const SizedBox(height: 10),
          statCard(context,
              kicker: 'Outstanding Balance',
              value: money(l.totalOutstanding),
              accent: true),
        ],
      ),
    );
  }
}
