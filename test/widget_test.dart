import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yazdyr/ledger.dart';
import 'package:yazdyr/store.dart';

// Runnable check for the money logic + the gap we closed (search/sort).
// Uses a temp-dir JSON store — pure Dart, no path_provider needed.
Future<Ledger> _freshLedger() async {
  final dir = await Directory.systemTemp.createTemp('yazdyr_test');
  final ledger = Ledger(Store(dir));
  await ledger.init();
  return ledger;
}

void main() {
  test('balance = credits - payments on seed data', () async {
    final l = await _freshLedger();
    // c1 Aýgül: credits 45 + 80, payment 20 → 105
    final c1 = l.customers.firstWhere((c) => c.id == 'c1');
    expect(c1.balance, 105);
    // c2 Serdar: credits 150 + 60, no payment → 210
    final c2 = l.customers.firstWhere((c) => c.id == 'c2');
    expect(c2.balance, 210);
  });

  test('addCredit and recordPayment move the balance', () async {
    final l = await _freshLedger();
    final before = l.customers.firstWhere((c) => c.id == 'c1').balance; // 105
    await l.addCredit('c1', amount: 50, desc: 'Test');
    expect(l.customers.firstWhere((c) => c.id == 'c1').balance, before + 50);
    await l.recordPayment('c1', amount: 30);
    expect(l.customers.firstWhere((c) => c.id == 'c1').balance,
        before + 50 - 30);
  });

  test('customersView search filters by name and phone', () async {
    final l = await _freshLedger();
    l.setSearchQuery('serdar');
    expect(l.customersView.length, 1);
    expect(l.customersView.first.id, 'c2');

    l.setSearchQuery('112233'); // Aýgül's phone
    expect(l.customersView.single.id, 'c1');
  });

  test('customersView sort modes order correctly', () async {
    final l = await _freshLedger();

    l.setSortMode('alpha');
    final alpha = l.customersView.map((c) => c.name).toList();
    final sorted = [...alpha]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    expect(alpha, sorted);

    l.setSortMode('debt');
    final debts = l.customersView.map((c) => c.balance).toList();
    for (var i = 1; i < debts.length; i++) {
      expect(debts[i] <= debts[i - 1], isTrue);
    }
  });

  test('data persists across reload', () async {
    final dir = await Directory.systemTemp.createTemp('yazdyr_persist');
    final l1 = Ledger(Store(dir));
    await l1.init();
    await l1.addCustomer(name: 'Persisted Person');
    final l2 = Ledger(Store(dir));
    await l2.init();
    expect(l2.customers.any((c) => c.name == 'Persisted Person'), isTrue);
  });
}
