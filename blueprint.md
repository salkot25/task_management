## Blueprint

### Overview

This application is a personal finance tracker with a password management feature. It allows users to securely store and manage their website login credentials.

### Features

- Securely store website usernames and passwords.
- View a list of all saved accounts.
- Copy username or password to the clipboard with a single tap.
- Edit existing account details.
- Delete accounts.
- Modern and eye-catching design for account list items.
- Add and edit account details using a popup dialog.

### Plan

**Goal:** Implement adding and editing account details using a popup dialog in `AccountListPage`, similar to the add task functionality.

**Steps:**

1. Modify `AccountListPage` to call a new method `_showAccountDetailDialog` when adding or editing an account.
2. Create `_showAccountDetailDialog` method in `_AccountListPageState` to display `AccountDetailPage` (or its content) as a dialog using `showDialog`.
3. Adapt `AccountDetailPage` (or create a new widget for the dialog content) to function without a `Scaffold`, including form fields, validation, and action buttons (Cancel, Save/Update).
4. Ensure data is correctly passed to the dialog for editing, and handle the case for adding a new account.
5. Update the account list by calling `provider.loadAccounts()` after the dialog is closed.
6. Remove the old page-based navigation for add/edit.
7. Run `dart format .` and `flutter analyze`.
8. Update the blueprint.md.
