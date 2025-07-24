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
- Filter accounts by website in the AppBar.
- Modern and eye-catching Bottom Navigation Bar design.

### Plan

**Goal:** Change the design of the Bottom Navigation Bar to match the provided image, with a rounded background for the selected item's icon.

**Steps:**

1. Modify the `BottomNavigationBar` widget in `lib/main.dart`.
2. Set the background color to a light color from the theme.
3. Adjust `selectedItemColor` and `unselectedItemColor` using theme colors.
4. Customize each `BottomNavigationBarItem`:
    - For the selected item, wrap the `icon` in a `Container` with `BoxDecoration` to create the rounded background effect.
    - For unselected items, use standard `Icon` and `Text`.
    - Adjust padding and margin within `BottomNavigationBarItem` or the icons/labels to achieve the desired spacing and alignment.
5. Ensure `showUnselectedLabels` is true.
6. Verify the updated design in the preview.
7. Run `dart format .` and `flutter analyze`.
8. Update the blueprint.md.
