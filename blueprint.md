# Application Blueprint

## Overview

This is a Flutter application integrated with Firebase. It includes features for authentication (login, registration, profile), account management, cash card transactions, and a task planner.

## Detailed Outline

### Authentication:

- Login Page: Allows users to sign in with email and password or Google Sign-In.
- Registration Page: Allows new users to create an account with email and password.
- Profile Page: Displays user information and provides a logout option.
- Forgot Password Page: Allows users to reset their password.
- Auth Checker: Handles redirection based on the user's authentication status.
- Uses Firebase Authentication.
- **Profile Integration with Firestore:**
    - Profile Entity: Represents a user's profile with fields like uid, name, and profilePictureUrl.
    - Profile Firestore Data Source: Handles CRUD operations for profiles in Firestore.
    - Profile Repository: Abstract repository and implementation for profile data.
    - Use Cases: CreateProfile, GetProfile, and UpdateProfile.
    - Auth Provider: Updated to manage profile state and interact with profile use cases.
    - Profile Page: Modified to display and allow editing of profile data.

### Account Management:

- Account Entity: Represents a user's account.
- Account Repository: Handles data operations for accounts (Firestore).
- Use Cases: Create, get all, update, and delete accounts.
- Account List Page: Displays a list of user accounts.
- Account Detail Page: Displays details of a specific account.
- Account Provider: Manages the state for account management.

### Cash Card:

- Transaction Entity: Represents a cash card transaction.
- Transaction Repository: Handles data operations for transactions (Firestore).
- Cashcard Page: Displays cash card information and transactions.
- Cashcard Provider: Manages the state for cash card.

### Task Planner:

- Task Entity: Represents a task.
- Task Repository: Handles data operations for tasks (Firestore).
- Task Planner Page: Displays and manages user tasks.
- Task Provider: Manages the state for tasks.

### Core:

- Error Handling: Defines custom exceptions and failures.
- Use Cases: Base class for defining use cases.

### Utility:

- App Colors: Defines the color palette.
- App Theme: Configures the application theme.

## Plan for Current Change: Integrate profile into Firestore

1. Create `Profile` entity (Completed).
2. Create `ProfileFirestoreDataSource` (Completed).
3. Create `ProfileRepository` (Completed).
4. Create Profile Use Cases (Completed).
5. Update `AuthProvider` (Completed).
6. Modify `ProfilePage` (Completed).
7. Update `blueprint.md` (Completed).
