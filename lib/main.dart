import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'ledger.dart';
import 'screens/home.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YazdyrApp());
}

class YazdyrApp extends StatefulWidget {
  const YazdyrApp({super.key});

  @override
  State<YazdyrApp> createState() => _YazdyrAppState();
}

class _YazdyrAppState extends State<YazdyrApp> {
  Ledger? _ledger;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final docs = await getApplicationDocumentsDirectory();
    // External storage dir so a file manager can reach backups; null on the
    // rare device without it, in which case Store falls back to a docs subdir.
    final ext = await getExternalStorageDirectory();
    final backups = ext == null ? null : Directory(p.join(ext.path, 'backups'));
    final ledger = Ledger(Store(docs, backups));
    await ledger.init();
    unawaited(ledger.maybeAutoBackup()); // launch-time scheduled backup
    if (mounted) setState(() => _ledger = ledger);
  }

  @override
  Widget build(BuildContext context) {
    final ledger = _ledger;
    if (ledger == null) {
      // Splash while the local database opens/seeds (mirrors prototype splash).
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: const SplashScreen(),
      );
    }
    return LedgerScope(
      ledger: ledger,
      child: Builder(
        builder: (context) {
          final l = LedgerScope.of(context); // subscribe to theme changes
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ýazdyr',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: l.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
            // Raise the text-size floor ~15% for readability while still
            // honoring users who set an even larger system font scale.
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              minScaleFactor: 1.15,
              child: child!,
            ),
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
