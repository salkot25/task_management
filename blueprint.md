## Blueprint

### Overview

This application is a personal finance tracker with a password management feature. It allows users to securely store and manage their website login credentials.

### Features

- Securely store website usernames and passwords.
- View a list of all saved accounts.
- Copy username or password to the clipboard with a single tap.
- Edit existing account details.
- Delete accounts.
- Modern and eye-catching design for account list items with username and password displayed in `TextFormField`s.
- Add and edit account details using a popup dialog.

### Plan

**Goal:** Change the display of username and password in `AccountListItem` back to `TextFormField`s, integrating copy and password visibility functionality within them.

**Steps:**

1. Modify the `AccountListItem` widget in `lib/features/account_management/presentation/pages/account_list_page.dart`.
2. Replace the current `Row` widgets for username and password with `TextFormField`s.
3. Configure the `TextFormField` for username to be `readOnly` and include a copy icon in its `suffixIcon`.
4. Configure the `TextFormField` for password to be `readOnly`, `obscureText` (toggled by state), and include both a visibility toggle icon and a copy icon in its `suffixIcon`.
5. Adjust the `decoration` of the `TextFormField`s to fit the modern card design, potentially removing default borders.
6. Ensure copy to clipboard and password visibility toggle functionality works correctly.
7. Keep the website text and action buttons (Edit, Delete) as they are in the current card design.
8. Verify the updated design and functionality in the preview.
9. Run `dart format .` and `flutter analyze`.
10. Update the blueprint.md.
