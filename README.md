# Ýazdyr

Offline-first credit ledger for small shops (Turkmen market — TMT currency, EN/TK, `+993` phones).
Flutter Android app, implemented from the Claude Design prototype `Yazdyr Prototype.dc.html`.

Everything runs on-device: no server, no account, no internet required.

## Features

- **Dashboard** — total customers, outstanding debt, today's credit sales, highest debt, longest-without-payment, recent activity.
- **Customers** — searchable (name/phone) and sortable (A–Z / highest debt / recent) list, add/edit, empty-state preview.
- **Customer detail** — running balance, transaction history, Add Credit / Record Payment.
- **Activity** — feed filtered by period (today/week/month/custom range), type (all/credit/payment), sort (newest/amount).
- **Reports** — total credit given, payments received, outstanding balance.
- **Backup & Restore** — export/restore the ledger as a JSON file.
- **Settings** — language (EN/TK, partial per the prototype) and light/dark theme, both persisted.

## Run

```bash
flutter pub get
flutter run          # on a connected Android device / emulator
flutter test         # ledger logic: balances, credit/payment, search/sort, persistence
flutter analyze
```

## Architecture

| File | Role |
|------|------|
| `lib/models.dart` | `Customer` / `Txn`, balance = Σcredits − Σpayments |
| `lib/seed.dart` | 14 sample customers, seeded on first launch only |
| `lib/store.dart` | JSON-file persistence (`ledger.json`) + export/import |
| `lib/ledger.dart` | `Ledger` `ChangeNotifier` — state, actions, computed values |
| `lib/format.dart` | money/date formatting, partial EN/TK strings |
| `lib/theme.dart` | light/dark themes from the prototype design tokens |
| `lib/widgets.dart` | `LedgerScope` + shared UI pieces |
| `lib/screens/` | one screen per prototype view |

State flows through a single `Ledger` exposed via `LedgerScope` (an `InheritedNotifier`) —
no external state-management dependency.

## Notes / deviations from the prototype

- **Persistence is a JSON key-value store, not SQLite.** SQLite (`sqflite`) was the intended choice,
  but it and `file_picker`/`share_plus` were unavailable in the offline build environment (pub.dev
  unreachable). The JSON store in `store.dart` is a drop-in seam: swap it for a `sqflite` implementation
  with the same `load`/`save`/`exportTo`/`importLatest` surface — nothing else in the app changes.
- **Closed prototype gaps:** customer search + sort are actually applied (the prototype wired the UI but
  ignored it), and backup/export do real file I/O instead of just showing a toast.
- **Backup restore** reads the most recent `yazdyr-*.json` export (no file browser offline).
- `TODAY` is the real `DateTime.now()`; seed data keeps its fixed 2026-07 dates, so "Today's Credit
  Sales" reflects the real date.
- Turkmen localization is partial, matching the prototype's `STR` map.
