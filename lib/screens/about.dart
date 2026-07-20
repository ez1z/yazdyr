import 'package:flutter/material.dart';

import '../widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('About',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Ýazdyr',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Text('Version 1.0.0 (MVP)',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          Divider(height: 32, color: Theme.of(context).dividerColor),
          _para(context, 'Offline-first',
              'All data is stored on this device. Ýazdyr works fully without an internet connection — nothing is sent to a server.'),
          _para(context, 'Storage', l.storageInfoLabel),
          _para(context, 'Privacy',
              'Customer records stay on your phone. Nothing is collected, tracked, or shared.'),
        ],
      ),
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
