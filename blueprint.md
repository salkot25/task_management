## Blueprint

### Overview

This application is a personal finance tracker designed to help users manage their income and expenses. It includes features for adding transactions, viewing transaction history, and summarizing financial activity.

### Features

- Add new income and expense transactions with descriptions, amounts, and dates.
- View a list of all transactions.
- See a summary of total balance, total income, and total expense.
- Filter transactions by month and year.
- Modern and eye-catching design for transaction list items.

### Plan

**Goal:** Enhance the visual design of the transaction list items in the Cashcard page to be more modern and eye-catching.

**Steps:**

1. Modify the `ListView.builder` in `lib/features/cashcard/presentation/pages/cashcard_page.dart`.
2. Replace the existing `Card` and `ListTile` with a custom container that includes:
    - A more prominent display of the transaction amount with clear visual distinction between income and expense.
    - A modern card design with rounded corners and subtle shadows.
    - An icon indicating transaction type (income/expense) on the left.
    - Transaction description.
    - Transaction date.
    - Use colors from `lib/utils/app_colors.dart` to maintain theme consistency.
3. Ensure the design is responsive and works well on different screen sizes.
4. Verify the updated design in the preview.
5. Run `dart format .` and `flutter analyze` to ensure code quality.
6. Update the blueprint.md with the completed changes.