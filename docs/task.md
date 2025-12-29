# MoneyTrack — MVP Task Breakdown (1 Week)

## P0 — Must Have

### Day 1 — Project Setup
- [ ] Create Flutter project
- [ ] Add dependencies (hive, provider, fl_chart, intl, uuid)
- [ ] Setup CupertinoApp + Tab scaffold
- [ ] Hive init + open boxes
- [ ] Create CategoryEntity & TransactionEntity
- [ ] Seed default categories

### Day 2 — Transactions Home
- [ ] Home page UI
- [ ] Month switch (current month default)
- [ ] Group transactions by day
- [ ] Monthly totals: income / expense / balance
- [ ] Empty state (no crash when empty)

### Day 3 — Add / Edit Transaction
- [ ] Transaction form page
- [ ] Type switch (Expense / Income)
- [ ] Amount validation (>0)
- [ ] Category dropdown filtered by type
- [ ] Save + Edit logic
- [ ] Home refresh after save

### Day 4 — Delete Transaction
- [ ] Swipe to delete (Cupertino style)
- [ ] Confirm dialog
- [ ] Totals & list update immediately

### Day 5 — Statistics
- [ ] Stats tab UI
- [ ] Monthly summary
- [ ] Daily expense aggregation
- [ ] Bar chart (fl_chart)
- [ ] Month switch

### Day 6 — Categories & Search
- [ ] Categories list (Expense / Income segment)
- [ ] Add category (name, icon, color)
- [ ] Prevent delete if category in use
- [ ] Search transactions by note

### Day 7 — Settings & Polish
- [ ] Seed demo data (>= 20 transactions)
- [ ] Reset data
- [ ] Format money & date
- [ ] Final UI polish
- [ ] Write README

---

## P1 — Optional (If Time Allows)
- [ ] Filter sheet (type + category)
- [ ] Dark mode toggle
- [ ] Chart tooltip on bar tap

---

## Definition of Done
- [ ] App does not crash when data is empty
- [ ] All core flows work (Add/Edit/Delete)
- [ ] Stats chart reflects real data
- [ ] Demo data available for presentation
- [ ] README explains features & run steps
