import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format.dart';
import '../widgets.dart';

// Native intents for off-device export/import (share_plus / file_picker are
// uncached offline). Mirrors the yazdyr/url channel in widgets.dart.
//   share(path) -> ACTION_SEND the file via FileProvider
//   import()    -> ACTION_OPEN_DOCUMENT, returns the picked file's text (or null)
const _backupChannel = MethodChannel('yazdyr/backup');

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context); // subscribe: last-backup label refreshes
    final last = l.lastBackup.isEmpty
        ? l.t('lastBackupNever')
        : l.t('lastBackup')
            .replaceFirst('{date}', localDateTime(l.lastBackup, l.language));

    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('backupRestore'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(l.t('backupInterval'), style: const TextStyle(fontSize: 14))),
              DropdownButton<String>(
                value: l.backupInterval,
                underline: const SizedBox.shrink(),
                onChanged: (v) => l.setBackupInterval(v ?? 'off'),
                items: [
                  for (final e in const {
                    'off': 'intervalOff',
                    'daily': 'intervalDaily',
                    'weekly': 'intervalWeekly',
                    'monthly': 'intervalMonthly',
                  }.entries)
                    DropdownMenuItem(value: e.key, child: Text(l.t(e.value))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(last,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _backupNow,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(l.t('backupNow')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _shareExport,
            icon: const Icon(Icons.ios_share, size: 18),
            label: Text(l.t('shareExport')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _exportExcel,
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: Text(l.t('exportExcel')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _import,
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: Text(l.t('importBackup')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _restoreLocal,
            icon: const Icon(Icons.restore, size: 18),
            label: Text(l.t('restoreLocal')),
          ),
        ],
      ),
    );
  }

  Future<void> _backupNow() async {
    final l = LedgerScope.read(context);
    await l.backupNow();
    if (mounted) showToast(context, l.t('backupDone'));
  }

  Future<void> _shareExport() async {
    final l = LedgerScope.read(context);
    final f = await l.backupNow(); // fresh backup, then hand its path to native
    try {
      await _backupChannel.invokeMethod('share', {
        'path': f.path,
        'mime': 'application/json',
      });
    } catch (_) {} // no handler off Android — the local backup still happened
    if (mounted) showToast(context, l.t('backupDone'));
  }

  Future<void> _exportExcel() async {
    final l = LedgerScope.read(context);
    final f = await l.exportXlsx();
    try {
      await _backupChannel.invokeMethod('share', {
        'path': f.path,
        'mime':
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      });
    } catch (_) {} // no handler off Android — the file still exists locally
    if (mounted) showToast(context, l.t('exportDone'));
  }

  Future<void> _import() async {
    final l = LedgerScope.read(context);
    String? text;
    try {
      text = await _backupChannel.invokeMethod<String>('import');
    } catch (_) {
      if (mounted) showToast(context, l.t('importInvalid'));
      return;
    }
    if (text == null) return; // user cancelled
    try {
      await l.importJson(text);
      if (mounted) showToast(context, l.t('restoreDone'));
    } catch (_) {
      if (mounted) showToast(context, l.t('importInvalid'));
    }
  }

  Future<void> _restoreLocal() async {
    final l = LedgerScope.read(context);
    final files = await l.listBackups();
    if (!mounted) return;
    if (files.isEmpty) {
      showToast(context, l.t('noBackups'));
      return;
    }
    final chosen = await showModalBottomSheet<File>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final f in files)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(_stampLabel(f, l.language)),
                onTap: () => Navigator.of(ctx).pop(f),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.t('restoreConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.t('restore'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await l.restoreFile(chosen);
    if (mounted) showToast(context, l.t('restoreDone'));
  }

  // 'backup-20260722-153045.json' -> localized '22 Iýul, 15:30'; falls back to
  // the raw filename if the stamp doesn't parse.
  String _stampLabel(File f, String lang) {
    final m = RegExp(r'backup-(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})')
        .firstMatch(f.uri.pathSegments.last);
    if (m == null) return f.uri.pathSegments.last;
    final iso = '${m[1]}-${m[2]}-${m[3]}T${m[4]}:${m[5]}:${m[6]}';
    final label = localDateTime(iso, lang);
    return label.isEmpty ? f.uri.pathSegments.last : label;
  }
}
