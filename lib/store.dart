import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'models.dart';

// Container for everything persisted: the customer list plus UI prefs.
class LedgerData {
  final List<Customer> customers;
  final String theme; // 'light' | 'dark'
  final String language; // 'en' | 'tk'
  const LedgerData({
    required this.customers,
    this.theme = 'light',
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'version': 1,
        'meta': {'theme': theme, 'language': language},
        'customers': customers.map((c) => c.toJson()).toList(),
      };

  factory LedgerData.fromJson(Map<String, dynamic> j) {
    final meta = (j['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LedgerData(
      customers: ((j['customers'] as List?) ?? const [])
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList(),
      theme: (meta['theme'] as String?) ?? 'light',
      language: (meta['language'] as String?) ?? 'en',
    );
  }
}

// JSON-file persistence. One file (`ledger.json`) under [dataDir]; exports go
// to [exportDir]. `dataDir`/`exportDir` are injected so this class stays free of
// path_provider and is testable headless with a temp dir.
//
// ponytail: JSON blob is plenty for hundreds of records. Swap this class for a
// sqflite-backed store (same load/save/export/import surface) if the ledger ever
// grows to thousands of rows or needs partial queries — the rest of the app only
// touches LedgerData, not the storage format.
class Store {
  final Directory dataDir;
  final Directory exportDir;
  Store(this.dataDir, {Directory? exportDir})
      : exportDir = exportDir ?? dataDir;

  File get _file => File(p.join(dataDir.path, 'ledger.json'));

  // Load persisted data, or seed + persist on first run.
  Future<LedgerData> load() async {
    final f = _file;
    if (await f.exists()) {
      final data = LedgerData.fromJson(
          jsonDecode(await f.readAsString()) as Map<String, dynamic>);
      return data;
    }
    const empty = LedgerData(customers: []);
    await save(empty);
    return empty;
  }

  // Write to a temp file then rename over the target: rename is atomic on the
  // same volume, so a crash mid-write can't truncate ledger.json and lose the
  // whole ledger — you keep either the old file or the fully-written new one.
  Future<void> save(LedgerData data) async {
    if (!await dataDir.exists()) await dataDir.create(recursive: true);
    final tmp = File(p.join(dataDir.path, 'ledger.json.tmp'));
    await tmp.writeAsString(jsonEncode(data.toJson()), flush: true);
    await tmp.rename(_file.path);
  }

  // Export/backup: write a timestamped copy to external storage. Returns the
  // filename shown in the confirmation toast.
  Future<String> exportTo(LedgerData data) async {
    if (!await exportDir.exists()) await exportDir.create(recursive: true);
    final name = 'yazdyr-export-${todayStamp()}.json';
    await File(p.join(exportDir.path, name))
        .writeAsString(jsonEncode(data.toJson()));
    return name;
  }

  // Import/restore: read the most recent yazdyr-*.json from the export dir.
  // (No file_picker offline — restoring the latest backup is the offline path.)
  Future<LedgerData?> importLatest() async {
    if (!await exportDir.exists()) return null;
    final files = exportDir
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('yazdyr-') &&
            f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    if (files.isEmpty) return null;
    final data = LedgerData.fromJson(
        jsonDecode(await files.first.readAsString()) as Map<String, dynamic>);
    await save(data);
    return data;
  }
}

String todayStamp() {
  final d = DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
