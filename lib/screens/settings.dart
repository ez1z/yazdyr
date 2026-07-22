import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets.dart';
import 'about.dart';
import 'reports.dart';

// Opens a URL via a tiny native intent (url_launcher is uncached offline).
const _urlChannel = MethodChannel('yazdyr/url');
Future<void> _openUrl(String url) async {
  try {
    await _urlChannel.invokeMethod('open', url);
  } catch (_) {
    // No handler (e.g. non-Android) or no app to open it — nothing to do.
  }
}

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
              ButtonSegment(value: 'ru', label: Text('RU')),
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
        _row(
          context,
          l.t('autoSendSms'),
          trailing: Switch(
            value: l.autoSendSms,
            onChanged: l.setAutoSendSms,
          ),
        ),
        _link(context, l.t('reports'), const ReportsScreen()),
        _link(context, l.t('about'), const AboutScreen()),
        const SizedBox(height: 28),
        _credit(context),
      ],
    );
  }

  // App author credit. Not translated — it's a name and a handle.
  Widget _credit(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Column(
      children: [
        Text('Eziz Agamyradov',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
        const SizedBox(height: 2),
        InkWell(
          onTap: () => _openUrl('https://instagram.com/ezxz.a'),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text('Instagram @ezxz.a',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary)),
          ),
        ),
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
                size: 22,
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
