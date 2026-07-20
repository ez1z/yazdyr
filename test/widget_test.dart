import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yazdyr/ledger.dart';
import 'package:yazdyr/store.dart';

// Runnable check for the money logic + the gap we closed (search/sort).
// Uses a temp-dir JSON store — pure Dart, no path_provider needed.
// The store seeds empty, so each test builds the fixtures it needs.
Future<Ledger> _freshLedger() async {
  final dir = await Directory.systemTemp.createTemp('yazdyr_test');
  final ledger = Ledger(Store(dir));
  await ledger.init();
  return ledger;
}

// Two customers with known balances: Aýgül → 105, Serdar → 210.
Future<Ledger> _seededLedger() async {
  final l = await _freshLedger();
  await l.addCustomer(name: 'Aýgül', phone: '112233');
  final aygul = l.customers.first.id;
  await l.addCredit(aygul, amount: 45);
  await l.addCredit(aygul, amount: 80);
  await l.recordPayment(aygul, amount: 20); // 45 + 80 - 20 = 105

  await l.addCustomer(name: 'Serdar', phone: '445566');
  final serdar = l.customers.first.id;
  await l.addCredit(serdar, amount: 150);
  await l.addCredit(serdar, amount: 60); // 150 + 60 = 210
  return l;
}

void main() {
  test('balance = credits - payments', () async {
    final l = await _seededLedger();
    expect(l.customers.firstWhere((c) => c.name == 'Aýgül').balance, 105);
    expect(l.customers.firstWhere((c) => c.name == 'Serdar').balance, 210);
  });

  test('addCredit and recordPayment move the balance', () async {
    final l = await _seededLedger();
    final id = l.customers.firstWhere((c) => c.name == 'Aýgül').id;
    final before = l.customers.firstWhere((c) => c.id == id).balance; // 105
    await l.addCredit(id, amount: 50, desc: 'Test');
    expect(l.customers.firstWhere((c) => c.id == id).balance, before + 50);
    await l.recordPayment(id, amount: 30);
    expect(l.customers.firstWhere((c) => c.id == id).balance,
        before + 50 - 30);
  });

  test('customersView search filters by name and phone', () async {
    final l = await _seededLedger();
    l.setSearchQuery('serdar');
    expect(l.customersView.length, 1);
    expect(l.customersView.first.name, 'Serdar');

    l.setSearchQuery('112233'); // Aýgül's phone
    expect(l.customersView.single.name, 'Aýgül');
  });

  test('customersView sort modes order correctly', () async {
    final l = await _seededLedger();

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
