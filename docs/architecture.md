# MoneyTrack — Architecture & Technical Design (MVP)

## 1. Overview
MoneyTrack là ứng dụng Flutter ghi Thu/Chi cá nhân, hoạt động offline-first.
UI theo phong cách iOS (Cupertino). Dữ liệu lưu local bằng Hive.

MVP tập trung vào:
- Ghi giao dịch nhanh
- Xem tổng quan theo tháng
- Xem xu hướng chi tiêu theo ngày (bar chart)

Không có login, cloud sync, multi-user trong MVP.

---

## 2. Tech Stack
- Flutter (Cupertino UI)
- Local DB: hive, hive_flutter
- State management: provider
- Chart: fl_chart
- Utils: uuid, intl

---

## 3. App Structure (Feature-first)

lib/
main.dart
app.dart

core/
theme/
utils/
widgets/

data/
hive/
hive_init.dart
boxes.dart
models/
transaction_entity.dart
category_entity.dart
settings_entity.dart
repositories/
transaction_repository.dart
category_repository.dart
settings_repository.dart

features/
transactions/
presentation/
pages/
widgets/
state/
stats/
presentation/
pages/
widgets/
state/
settings/
presentation/
pages/
widgets/
state/

---

## 4. Data Layer

### Hive Boxes
- transactionsBox
- categoriesBox
- settingsBox (optional)

### Entities

#### TransactionEntity
- id: String
- type: int (0 = expense, 1 = income)
- amount: double
- categoryId: String
- date: DateTime
- note: String

#### CategoryEntity
- id: String
- type: int (0 = expense, 1 = income)
- name: String
- iconCode: int
- colorValue: int

---

## 5. Business Rules
- amount > 0
- category.type must match transaction.type
- Category cannot be deleted if used by any transaction
- App must not crash when boxes are empty

---

## 6. State Management (Provider)
- TransactionsVm
  - loadMonth(DateTime month)
  - addTransaction()
  - updateTransaction()
  - deleteTransaction()
  - searchAndFilter()
- StatsVm
  - loadMonth(DateTime month)
  - computeMonthlySummary()
  - computeDailyExpenseTotals()
- CategoriesVm
  - loadCategories(type)
  - addCategory()
  - deleteCategory() (check used)

State change must notify listeners immediately so Home & Stats refresh.

---

## 7. Screens & User Flow

### Tabs
1. Transactions
2. Statistics
3. Settings

### Add Transaction Flow
Home → "+" → Transaction Form → Save → Home refresh → Stats refresh

### Edit Transaction
Home tap item → Edit Form → Save → refresh

### Statistics
Stats tab → change month → summary + chart update

### Category
Settings → Categories → Add → back → Form picker shows new category

---

## 8. Statistics Logic
- Bar chart shows total **expense** per day in selected month
- X axis: day 1..n
- Y axis: sum(expense.amount)
- Days with no expense = 0 (still displayed)

---

## 9. Non-goals (Out of Scope)
- Login / authentication
- Cloud sync
- Multi-currency
- Recurring transactions
- Receipt scanning / AI categorization
