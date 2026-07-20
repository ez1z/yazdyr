import 'package:flutter/material.dart';

import '../widgets.dart';
import 'about.dart';
import 'backup.dart';
import 'reports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
      children: [
        Text(l.t('navSettings'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _row(
          context,
          l.t('language'),
          trailing: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('EN')),
              ButtonSegment(value: 'tk', label: Text('TK')),
            ],
            selected: {l.language},
            showSelectedIcon: false,
            onSelectionChanged: (s) => l.setLanguage(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        _row(
          context,
          l.t('theme'),
          trailing: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'light', label: Text(l.t('themeLight'))),
              ButtonSegment(value: 'dark', label: Text(l.t('themeDark'))),
            ],
            selected: {l.theme},
            showSelectedIcon: false,
            onSelectionChanged: (s) => l.setTheme(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        _link(context, l.t('backupRestore'), const BackupScreen()),
        _link(context, l.t('reports'), const ReportsScreen()),
        _link(context, l.t('about'), const AboutScreen()),
      ],
    );
  }

  Widget _row(BuildContext context, String label, {required Widget trailing}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          trailing,
        ],
      ),
    );
  }

  Widget _link(BuildContext context, String label, Widget target) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => target)),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Icon(Icons.chevron_right,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
