# Ýazdyr

Offline-first credit ledger for small shops (Turkmen market — TMT, EN/TK, `+993`).
Flutter Android app. Everything runs on-device: no server, no account, no internet.

## Features

- **Dashboard** — customers, outstanding debt, today's credit sales, highest debt, longest-without-payment, recent activity.
- **Customers** — searchable (name/phone) and sortable (A–Z / debt / recent) list, add/edit, running balance + history per customer.
- **Activity** — feed filtered by period (today/week/month/custom), type (credit/payment), and sort (newest/amount).
- **Reports** — credit given, payments received, outstanding balance.
- **Settings** — language (EN/TK/RU) and light/dark theme, both persisted.

## Run

```bash
flutter pub get
flutter run       # connected Android device / emulator
flutter test      # ledger logic: balances, credit/payment, search/sort, persistence
flutter analyze
```

## Architecture

State lives in a single `Ledger` (`ChangeNotifier`), exposed to the widget tree via
`LedgerScope` (an `InheritedNotifier`) — no external state-management dependency. Screens
read computed getters and call mutation methods; every mutation calls `notifyListeners()`
then persists.

```
UI (screens/) ──reads──▶ Ledger getters (computed)
     │                        ▲
     └──calls──▶ Ledger mutations ──▶ Store.save() ──▶ ledger.json
```

**Data model** (`lib/models.dart`):

- `Customer { id, name, phone, address, notes, transactions[] }`
- `Txn { id, type: 'credit'|'payment', amount, label, date }`
- `balance = Σ credits − Σ payments`; transactions are kept sorted newest-first.

**Persistence** (`lib/store.dart`) is a JSON key-value store (`ledger.json`). It's an
intentional seam: swap it for a `sqflite` implementation behind the same
`load` / `save` surface and nothing else changes. (SQLite was
the intended backend but was unreachable in the offline build environment.)

### File map

| Path               | Role                                                             |
| ------------------ | ---------------------------------------------------------------- |
| `lib/models.dart`  | `Customer` / `Txn`, balance math                                 |
| `lib/ledger.dart`  | `Ledger` — state, mutations, `renderVals`-style computed getters |
| `lib/store.dart`   | JSON persistence                                                 |
| `lib/seed.dart`    | sample customers, seeded on first launch only                    |
| `lib/format.dart`  | money/date formatting, EN/TK strings (`tr`)                      |
| `lib/theme.dart`   | light/dark themes from the prototype design tokens               |
| `lib/widgets.dart` | `LedgerScope` + shared UI pieces                                 |
| `lib/screens/`     | one screen per prototype view                                    |

The app is ported from the Claude Design prototype `Yazdyr Prototype.dc.html` — its
`renderVals()` / `computeCustomer` are the behavioral spec, mirrored in `ledger.dart`.

## Contributing

1. Fork, branch, and make sure `flutter analyze` and `flutter test` pass before opening a PR.
2. **Stay offline-first** — no server calls, no telemetry, no cloud deps.
3. **No new state-management deps.** Add state as fields/getters/methods on `Ledger`; keep
   computed values as getters so they mirror the prototype's `renderVals`.
4. **Persisted vs. transient** — anything that must survive a restart goes into `LedgerData`
   and `_persist()`; filter/search/selection state stays transient (see the sections in
   `ledger.dart`).
5. Behavior should match `Yazdyr Prototype.dc.html`; note any deliberate deviation in the PR.
6. Cover non-trivial ledger logic (balances, filters, import/export) with a test.

Good first issues: finish the Turkmen (`tk`) strings in `format.dart`, add a real file
picker for restore, or add per-customer transaction editing/deletion.

---

> Or just fork this, copy the README verbatim, and hand it to the AI whose output
> you'll never actually read or understand. We won't tell.

This project created after I waited half an hour in queue till the cashier find the ledger written page of the current customer.
