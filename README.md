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
- Create bank or cash accounts in Settings with their starting balance. When
  recording an income or payment without an account, the app offers to create
  one and then continues the operation.
- The dashboard highlights Safe to Spend, daily limit and payday, monthly income
  and spending, upcoming or overdue obligations, category spending, and the
  latest transactions.
- The Operations tab supports searchable, date/account/category/type-filtered
  transaction history, income and expense creation/editing/deletion, and
  paired same-currency transfers that update both account balances.

## Development

```shell
flutter pub get
flutter analyze
flutter test
```
