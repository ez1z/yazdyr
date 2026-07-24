import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yazdyr/ledger.dart';
import 'package:yazdyr/store.dart';
import 'package:yazdyr/xlsx.dart';

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

  test('backupNow writes a file and stamps lastBackup', () async {
    final l = await _seededLedger();
    expect(l.lastBackup, '');
    final f = await l.backupNow();
    expect(await f.exists(), isTrue);
    expect(l.lastBackup, isNot(''));
    expect((await l.listBackups()).length, 1);
  });

  test('prune keeps only the newest 5 backups', () async {
    final l = await _seededLedger();
    final dir = l.store.backupDir;
    await dir.create(recursive: true);
    // Seed 6 pre-existing backups with distinct (chronological) filenames.
    for (var i = 0; i < 6; i++) {
      await File('${dir.path}/backup-20260101-0000${i.toString().padLeft(2, '0')}.json')
          .writeAsString('{"meta":{},"customers":[]}');
    }
    expect((await l.listBackups()).length, 6);
    await l.store.writeBackup(_dummy(0)); // triggers prune to 5
    expect((await l.listBackups()).length, 5);
  });

  test('restore replaces data and snapshots current first', () async {
    final l = await _seededLedger();
    final backup = l.store.parse(
        '{"meta":{},"customers":[{"id":"c1","name":"Restored","transactions":[]}]}');
    final countBefore = (await l.listBackups()).length;
    await l.restore(backup);
    expect(l.customers.length, 1);
    expect(l.customers.single.name, 'Restored');
    // A pre-restore snapshot of the old data was written.
    expect((await l.listBackups()).length, countBefore + 1);
  });

  test('importJson rejects malformed input', () async {
    final l = await _seededLedger();
    final before = l.customers.length;
    expect(() => l.importJson('not json'), throwsA(anything));
    expect(l.customers.length, before); // unchanged
  });

  test('maybeAutoBackup respects the interval', () async {
    final l = await _seededLedger();
    // off => no backup
    await l.maybeAutoBackup();
    expect((await l.listBackups()).length, 0);
    // weekly, never backed up => backs up
    l.setBackupInterval('weekly');
    await l.maybeAutoBackup();
    expect((await l.listBackups()).length, 1);
    // just backed up => within interval, no second backup
    await l.maybeAutoBackup();
    expect((await l.listBackups()).length, 1);
  });

  test('crc32 matches the standard check vector', () {
    // "123456789" -> 0xCBF43926 is the canonical CRC-32 test value.
    expect(crc32('123456789'.codeUnits), 0xCBF43926);
  });

  test('buildXlsx produces a valid ZIP with the sheet content', () {
    final bytes = buildXlsx([
      XlsxSheet('Customers', [
        ['Name', 'Balance'],
        ['Aygul', 105],
      ]),
    ]);
    // ZIP local-file-header magic 'PK\x03\x04' and EOCD magic 'PK\x05\x06'.
    expect(bytes.sublist(0, 4), [0x50, 0x4B, 0x03, 0x04]);
    expect(bytes.sublist(bytes.length - 22, bytes.length - 18),
        [0x50, 0x4B, 0x05, 0x06]);
    final text = String.fromCharCodes(bytes);
    expect(text.contains('Aygul'), isTrue);
    expect(text.contains('<v>105</v>'), isTrue);
    expect(text.contains('styles.xml'), isTrue); // styles part present
    expect(text.contains('s="1"'), isTrue); // header row is bold-styled
  });

  test('exportXlsx styles currency cells with the TMT format', () async {
    final l = await _seededLedger();
    final f = await l.exportXlsx();
    final text = String.fromCharCodes(await f.readAsBytes());
    expect(text.contains('s="2"'), isTrue); // Money cells use the TMT numFmt
  });

  test('exportXlsx writes an .xlsx file', () async {
    final l = await _seededLedger();
    final f = await l.exportXlsx();
    expect(await f.exists(), isTrue);
    expect(f.path.endsWith('.xlsx'), isTrue);
    expect((await f.readAsBytes()).sublist(0, 2), [0x50, 0x4B]); // 'PK'
  });
}

LedgerData _dummy(int i) =>
    LedgerData(customers: const [], lastBackup: 'x$i');
