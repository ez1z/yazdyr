import 'package:flutter/material.dart';

import '../widgets.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('backupRestore'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _button(context, Icons.file_download_outlined, l.t('exportDatabase'),
              _export),
          const SizedBox(height: 10),
          _button(context, Icons.file_upload_outlined, l.t('importDatabase'),
              _restore),
          const SizedBox(height: 10),
          _button(context, Icons.inventory_2_outlined, l.t('createBackup'),
              _export),
          const SizedBox(height: 10),
          _button(context, Icons.restore, l.t('restoreBackup'), _restore),
          const SizedBox(height: 16),
          Text(l.t('backupLocalNote'),
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final l = LedgerScope.read(context);
    final name = await l.exportBackup();
    if (context.mounted) {
      showToast(context, l.t('toastBackupCreated').replaceFirst('{name}', name));
    }
  }

  Future<void> _restore(BuildContext context) async {
    final l = LedgerScope.read(context);
    final ok = await l.restoreBackup();
    if (context.mounted) {
      showToast(context, ok ? l.t('toastRestored') : l.t('toastNoBackup'));
    }
  }

  Widget _button(BuildContext context, IconData icon, String label,
      Future<void> Function(BuildContext) onTap) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: () => onTap(context),
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center),
      ),
    );
  }
}
