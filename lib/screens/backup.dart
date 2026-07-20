import 'package:flutter/material.dart';

import '../widgets.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Backup & Restore',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _button(context, Icons.file_download_outlined, 'Export Database',
              _export),
          const SizedBox(height: 10),
          _button(context, Icons.file_upload_outlined, 'Import Database',
              _restore),
          const SizedBox(height: 10),
          _button(context, Icons.inventory_2_outlined, 'Create Backup',
              _export),
          const SizedBox(height: 10),
          _button(context, Icons.restore, 'Restore Backup', _restore),
          const SizedBox(height: 16),
          Text('Everything works locally — no internet connection required.',
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
    if (context.mounted) showToast(context, 'Backup created — $name');
  }

  Future<void> _restore(BuildContext context) async {
    final l = LedgerScope.read(context);
    final ok = await l.restoreBackup();
    if (context.mounted) {
      showToast(context,
          ok ? 'Database restored from last backup' : 'No backup found yet');
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
