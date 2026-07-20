# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Ýazdyr — an offline-first credit ledger (debt book) for small shops. Flutter/Dart, Android-targeted. Currency is TMT; default language is Turkmen (`tk`), with English and Russian.

## Commands

```bash
flutter run                         # run on a connected device/emulator
flutter test                        # run all tests
flutter test test/widget_test.dart  # single file
flutter test --plain-name "search"  # single test by name substring
flutter analyze                     # lint (flutter_lints, see analysis_options.yaml)
flutter build apk                   # release build
```

Tests are pure-Dart and headless: they drive `Ledger` over a temp-dir `Store`, so no emulator or `path_provider` is needed.

## Offline build constraint

This project builds with **no pub.dev / GitHub access**. Only packages already in `pubspec.lock` are available: `path_provider` and `path`. Do **not** add dependencies (sqflite, file_picker, share_plus, etc. are uncached and will fail). Solve with the SDK + these two packages, or plain Dart.

## Architecture

The app is a port of a Claude Design HTML prototype (`Yazdyr Prototype.dc.html`); its `renderVals()` / `computeCustomer()` are the behavioral spec. Layers, inner → outer:

- **`lib/models.dart`** — `Customer` and `Txn`, immutable with `copyWith` + `toJson`/`fromJson`. `balance = Σ credits − Σ payments`. Transactions are kept newest-first via `.sorted()`.
- **`lib/store.dart`** — JSON-file persistence. Everything lives in one `ledger.json` under the app documents dir; `save()` writes to a temp file then atomically renames (crash-safe). `Store` takes its dirs by injection so it stays free of `path_provider` and is testable. Exports are timestamped copies to external storage; "restore" reads the newest `yazdyr-*.json` (no file picker offline). ponytail note in-file explains swapping to sqflite if it ever outgrows a JSON blob.
- **`lib/ledger.dart`** — `Ledger extends ChangeNotifier`, the single source of truth. Holds persisted state (customers, theme, language) + transient UI state (search/sort/activity filters, selection). Every mutation calls `notifyListeners()` then `_persist()`. All computed dashboard/report values (`totalOutstanding`, `overdueList`, `customersView`, `activityList`, …) are getters here, mirroring the prototype's `renderVals()`.
- **`lib/widgets.dart`** — `LedgerScope` (an `InheritedNotifier<Ledger>`) is how screens reach the ledger: `LedgerScope.of(context)` subscribes and rebuilds on change; `LedgerScope.read(context)` is the non-subscribing read for `initState`/callbacks. Also shared UI helpers (`statCard`, `txRow`, `boxList`, `showToast`).
- **`lib/screens/`** — one file per screen. `home.dart` is the shell: splash while the ledger loads, then a 4-tab `NavigationBar` (Dashboard, Customers, Activity, Settings) over an `IndexedStack`. `switchToTab(context, i)` lets any descendant change tabs.

`main.dart` bootstraps: resolve dirs → build `Store` → `Ledger.init()` → wrap the app in `LedgerScope`.

## i18n (do not hardcode UI strings)

All user-facing text is keyed in the `_str` map in `lib/format.dart`, with full `en`/`tk`/`ru` entries. Access via `Ledger.t(key)` / `LedgerScope.of(context).t(key)`. Templates use `{name}` placeholders filled with `replaceFirst`. When adding UI text, add a key with all three languages — never inline a literal. User-entered data (customer names, transaction labels) is **not** translated. `format.dart` also holds `money()` (→ `'1,235 TMT'`), `shortDate()`, and `todayIso()`.
