import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'models.dart';

// Container for everything persisted: the customer list plus UI prefs.
class LedgerData {
  final List<Customer> customers;
  final String theme; // 'light' | 'dark'
  final String language; // 'en' | 'tk' | 'ru'
  final String backupInterval; // 'off' | 'daily' | 'weekly' | 'monthly'
  final String lastBackup; // ISO datetime of last backup, or '' if never
  // Custom SMS receipt templates; '' means fall back to the translated default.
  final String smsCreditTemplate;
  final String smsPaymentTemplate;
  const LedgerData({
    required this.customers,
    this.theme = 'light',
    this.language = 'tk',
    this.backupInterval = 'off',
    this.lastBackup = '',
    this.smsCreditTemplate = '',
    this.smsPaymentTemplate = '',
  });

  Map<String, dynamic> toJson() => {
        'version': 1,
        'meta': {
          'theme': theme,
          'language': language,
          'backupInterval': backupInterval,
          'lastBackup': lastBackup,
          'smsCreditTemplate': smsCreditTemplate,
          'smsPaymentTemplate': smsPaymentTemplate,
        },
        'customers': customers.map((c) => c.toJson()).toList(),
      };

  factory LedgerData.fromJson(Map<String, dynamic> j) {
    final meta = (j['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LedgerData(
      customers: ((j['customers'] as List?) ?? const [])
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList(),
      theme: (meta['theme'] as String?) ?? 'light',
      language: (meta['language'] as String?) ?? 'tk',
      backupInterval: (meta['backupInterval'] as String?) ?? 'off',
      lastBackup: (meta['lastBackup'] as String?) ?? '',
      smsCreditTemplate: (meta['smsCreditTemplate'] as String?) ?? '',
      smsPaymentTemplate: (meta['smsPaymentTemplate'] as String?) ?? '',
    );
  }
}

// JSON-file persistence. One file (`ledger.json`) under [dataDir]. `dataDir` is
// injected so this class stays free of path_provider and is testable headless
// with a temp dir.
//
// ponytail: JSON blob is plenty for hundreds of records. Swap this class for a
// sqflite-backed store (same load/save surface) if the ledger ever grows to
// thousands of rows or needs partial queries — the rest of the app only touches
// LedgerData, not the storage format.
class Store {
  final Directory dataDir;
  // Backups live in their own dir (external storage in the real app so a file
  // manager can reach them). Defaults to a subdir of dataDir so headless tests
  // that pass only dataDir still work. Kept to the newest [_keepBackups].
  final Directory backupDir;
  Store(this.dataDir, [Directory? backupDir])
      : backupDir = backupDir ?? Directory(p.join(dataDir.path, 'backups'));

  static const _keepBackups = 5;

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

  // ---- backups ----

  // Timestamped so filenames sort chronologically (lexicographic == time order),
  // which lets listBackups() and _prune() sort by name.
  // ponytail: second resolution — two backups in the same second would collide
  // and overwrite; add millis if that ever becomes real.
  String _stamp() {
    final d = DateTime.now();
    String p2(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${p2(d.month)}${p2(d.day)}-${p2(d.hour)}${p2(d.minute)}${p2(d.second)}';
  }

  // Write a full snapshot to backupDir, then prune to the newest [_keepBackups].
  Future<File> writeBackup(LedgerData data) async {
    if (!await backupDir.exists()) await backupDir.create(recursive: true);
    final f = File(p.join(backupDir.path, 'backup-${_stamp()}.json'));
    await f.writeAsString(jsonEncode(data.toJson()), flush: true);
    await _prune();
    return f;
  }

  // Backup files, newest first.
  Future<List<File>> listBackups() async {
    if (!await backupDir.exists()) return const [];
    final files = await backupDir
        .list()
        .where((e) =>
            e is File &&
            p.basename(e.path).startsWith('backup-') &&
            e.path.endsWith('.json'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path)); // newest (largest stamp) first
    return files;
  }

  Future<void> _prune() async {
    final files = await listBackups();
    for (final f in files.skip(_keepBackups)) {
      try {
        await f.delete();
      } catch (_) {} // best-effort; a failed delete just leaves an extra backup
    }
  }

  Future<LedgerData> readBackup(File f) async =>
      LedgerData.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);

  // Write arbitrary export bytes (e.g. an .xlsx) to backupDir, timestamped.
  // Not pruned — exports are user-initiated and tiny.
  Future<File> writeExport(String prefix, String ext, List<int> bytes) async {
    if (!await backupDir.exists()) await backupDir.create(recursive: true);
    final f = File(p.join(backupDir.path, '$prefix-${_stamp()}.$ext'));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  // Parse a raw JSON string into LedgerData (used by the native import picker).
  // Throws on malformed input.
  LedgerData parse(String jsonStr) =>
      LedgerData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
