# LinkedOut Authentication System

## Overview
I've implemented a complete multi-user authentication system that allows users to create separate accounts with their own credentials. Each user has their own isolated database for contacts and data.

## Features

### 1. User Registration & Login
- **Registration**: Users can create accounts with:
  - Username (required, must be unique, 3+ characters, alphanumeric + underscores)
  - Password (required, 6+ characters, securely hashed with SHA-256)
  - Display Name (optional)
  - Email (optional, with validation)

- **Login**: Users log in with username and password
- **Session Management**: Sessions persist across app restarts using SharedPreferences
- **Password Security**: All passwords are hashed using SHA-256 before storage

### 2. Data Isolation
- Each user has their own separate database (`linkedout_username`)
- Contacts and data are completely isolated between users
- User credentials are stored in a separate authentication database

### 3. User Interface
- **Login Screen**: Clean, dark-themed login interface
- **Registration Screen**: Full registration form with validation
- **Profile Screen**: Shows current logged-in user with logout button
- **Onboarding**: Per-user onboarding status tracking

## File Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── user.dart               # User model with Isar schema
│   │   └── auth_state.dart         # Authentication state enum
│   └── local/
│       └── database/
│           └── isar_service.dart   # Updated for multi-user databases
├── services/
│   └── auth/
│       ├── auth_service.dart       # Core authentication logic
│       └── auth_provider.dart      # State management with ChangeNotifier
└── presentation/
    └── screens/
        └── auth/
            ├── login_screen.dart       # Login UI
            └── register_screen.dart    # Registration UI
```

## How It Works

### Authentication Flow

1. **App Startup** (`main.dart`):
   - AuthProvider initializes and checks for existing session
   - If session found, user is automatically logged in
   - If no session, login screen is shown

2. **Login Process**:
   - User enters credentials on LoginScreen
   - AuthProvider calls AuthService.login()
   - Password is hashed and compared with stored hash
   - On success:
     - User session is saved
     - User's database is loaded
     - App navigates to home or onboarding

3. **Registration Process**:
   - User fills registration form
   - Validation ensures unique username and strong password
   - Password is hashed before storage
   - User is automatically logged in after registration

4. **Logout Process**:
   - User clicks logout in ProfileScreen
   - Confirmation dialog appears
   - User's database is closed
   - Session is cleared
   - App returns to login screen

### Database Structure

**Authentication Database** (`linkedout_auth`):
- Stores User accounts
- Contains username, hashed password, metadata
- Shared across all users

**User Databases** (`linkedout_{username}`):
- Separate database per user
- Contains Contact records
- Completely isolated from other users

### Security Features

- **Password Hashing**: SHA-256 hashing with crypto package
- **No Plain Text Storage**: Passwords never stored in plain text
- **Session Security**: Sessions stored securely in SharedPreferences
- **Input Validation**: Username and password requirements enforced
- **Unique Usernames**: Database constraint prevents duplicate usernames

## Usage Examples

### Creating a New Account
1. Launch the app
2. Click "Register" on login screen
3. Fill in:
   - Username: `john_doe`
   - Password: `securepass123`
   - Display Name: `John Doe` (optional)
   - Email: `john@example.com` (optional)
4. Click "Create Account"
5. You'll be automatically logged in

### Logging In
1. Enter your username and password
2. Click "Login"
3. Your contacts and data will load

### Logging Out
1. Go to Profile screen (tap profile icon in home screen)
2. Scroll to bottom
3. Click red "Logout" button
4. Confirm logout

### Switching Accounts
1. Logout from current account
2. Login with different credentials
3. Each account has its own separate contacts and data

## Technical Details

### Key Classes

**AuthService** (`services/auth/auth_service.dart`):
- Singleton service for authentication operations
- Methods: `register()`, `login()`, `logout()`, `restoreSession()`
- Handles password hashing and user database management

**AuthProvider** (`services/auth/auth_provider.dart`):
- ChangeNotifier for state management
- Provides authentication state to the entire app
- Methods: `initialize()`, `login()`, `register()`, `logout()`

**IsarService** (`data/local/database/isar_service.dart`):
- Manages multiple user databases
- Methods: `getUserDatabase()`, `switchUserDatabase()`, `closeUserDatabase()`
- Maintains map of open user databases

### State Management

The app uses Provider pattern with AuthProvider:
- `AuthState.initial` - App starting up
- `AuthState.loading` - Processing login/registration
- `AuthState.authenticated` - User logged in
- `AuthState.unauthenticated` - No user logged in
- `AuthState.error` - Authentication error occurred

### Navigation Flow

```
main.dart
  ↓
LinkedOutApp (listens to AuthProvider)
  ↓
  ├─ Loading → CircularProgressIndicator
  ├─ Authenticated → 
  │   ├─ Has completed onboarding → HomeScreen
  │   └─ Not completed onboarding → GetStartedScreen
  └─ Unauthenticated → LoginScreen
```

## Dependencies Added

```yaml
dependencies:
  crypto: ^3.0.3  # For SHA-256 password hashing
```

## Future Enhancements

Possible improvements for the authentication system:

1. **Password Reset**: Add email-based password recovery
2. **Biometric Auth**: Fingerprint/Face ID support
3. **Remember Me**: Optional persistent login
4. **Account Settings**: Change password, update email
5. **Multi-Factor Authentication**: SMS or authenticator app
6. **Account Deletion**: Full account removal with data cleanup
7. **Username Recovery**: Help users recover forgotten usernames
8. **Login History**: Track login attempts and sessions
9. **Password Strength Meter**: Visual feedback on password strength
10. **Social Login**: OAuth integration (Google, Apple, etc.)

## Notes

- Each user's onboarding status is tracked separately
- User databases are created on first login
- Databases remain on device even after logout (data persists)
- Multiple accounts can exist on same device
- No network/cloud sync - all data stored locally
