import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets.dart';

// Opens a URL via a tiny native intent (url_launcher is uncached offline).
const _urlChannel = MethodChannel('yazdyr/url');
Future<void> _openUrl(String url) async {
  try {
    await _urlChannel.invokeMethod('open', url);
  } catch (_) {
    // No handler (e.g. non-Android) or no app to open it — nothing to do.
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(l.t('about'),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Ýazdyr',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Text(l.t('version'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          Divider(height: 32, color: Theme.of(context).dividerColor),
          _para(context, l.t('aboutFeaturesTitle'), l.t('aboutFeaturesBody')),
          _para(context, l.t('aboutOfflineTitle'), l.t('aboutOfflineBody')),
          _para(context, l.t('storageTitle'), l.storageInfoLabel),
          _para(context, l.t('privacyTitle'), l.t('privacyBody')),
          Divider(height: 32, color: Theme.of(context).dividerColor),
          _credit(context),
        ],
      ),
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

  Widget _para(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}
