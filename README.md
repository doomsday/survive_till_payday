# Payday

Offline-first personal finance app built with Flutter, Drift/SQLite, and Riverpod.
Financial amounts are stored as integer KZT values; no backend or account is
required.

## Financial planning

- Add recurring obligations on weekly, monthly, quarterly, or yearly schedules.
  Future occurrences are generated locally and duplicate dates are not recreated.
- Edit or cancel an individual occurrence, record full or partial payments, and
  have payment transactions update the selected account balance.
- Record expected income on a recurring or one-off schedule. Marking it received
  adds an income transaction and prevents the forecast from counting it twice.
- Set a virtual reserve and the next payday. The dashboard calculates
  `Safe to Spend = active balances + expected income - unpaid obligations - reserve`
  for the current payday cycle, along with a non-negative daily limit.
- Add a quick expense from the dashboard.

## Development

```shell
flutter pub get
flutter analyze
flutter test
```
