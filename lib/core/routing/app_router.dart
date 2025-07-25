import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

// Import Authentication
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';
import 'package:myapp/features/auth/presentation/pages/register_page.dart';
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';

// Import Features
import 'package:myapp/features/account_management/presentation/pages/account_list_page.dart';
import 'package:myapp/features/task_planner/presentation/pages/task_planner_page.dart';
import 'package:myapp/features/cashcard/presentation/pages/cashcard_page.dart';

// Import Navigation Shell
import 'package:myapp/presentation/widgets/bottom_navigation_shell.dart';

/// App Router Configuration
/// Centralized routing configuration for better maintainability
class AppRouter {
  late final GoRouter _router;

  AppRouter(AuthProvider authProvider) {
    _router = _createRouter(authProvider);
  }

  GoRouter get router => _router;

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      routes: _buildRoutes(),
      redirect: (context, state) =>
          _handleRedirect(context, state, authProvider),
      refreshListenable: authProvider,
      initialLocation: '/tasks',
      debugLogDiagnostics: true,
    );
  }

  /// Builds the route configuration
  List<RouteBase> _buildRoutes() {
    return [
      // Root redirect
      GoRoute(path: '/', redirect: (context, state) => '/tasks'),

      // Authentication routes
      ..._buildAuthRoutes(),

      // Main app shell with bottom navigation
      _buildShellRoute(),
    ];
  }

  /// Builds authentication routes
  List<GoRoute> _buildAuthRoutes() {
    return [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
    ];
  }

  /// Builds the shell route with bottom navigation
  StatefulShellRoute _buildShellRoute() {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tasks branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const TaskPlannerPage(),
            ),
          ],
        ),

        // Vault branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              name: 'vault',
              builder: (context, state) => const AccountListPage(),
            ),
          ],
        ),

        // Cashcard branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cashcard',
              name: 'cashcard',
              builder: (context, state) => const CashcardPage(),
            ),
          ],
        ),

        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    );
  }

  /// Handles route redirects based on authentication state
  String? _handleRedirect(
    BuildContext context,
    GoRouterState state,
    AuthProvider authProvider,
  ) {
    final bool isAuthenticated = authProvider.user != null;
    final bool isAuthenticating = _isAuthRoute(state.uri.path);

    developer.log(
      'Route redirect check - Path: ${state.uri.path}, Authenticated: $isAuthenticated',
      name: 'AppRouter',
    );

    // Redirect unauthenticated users to login
    if (!isAuthenticated && !isAuthenticating) {
      developer.log(
        'Redirecting to login - user not authenticated',
        name: 'AppRouter',
      );
      return '/login';
    }

    // Redirect authenticated users away from auth pages
    if (isAuthenticated && isAuthenticating) {
      developer.log(
        'Redirecting to tasks - user already authenticated',
        name: 'AppRouter',
      );
      return '/tasks';
    }

    return null; // No redirect needed
  }

  /// Checks if the current path is an authentication route
  bool _isAuthRoute(String path) {
    const authPaths = ['/login', '/register', '/forgot-password'];
    return authPaths.contains(path);
  }
}

/// Route Names Constants
/// Centralized route name constants for type-safe navigation
abstract class AppRoutes {
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String tasks = 'tasks';
  static const String vault = 'vault';
  static const String cashcard = 'cashcard';
  static const String profile = 'profile';
}

/// Navigation Extensions
/// Helper methods for easier navigation
extension AppNavigation on BuildContext {
  /// Navigate to login page
  void goToLogin() => go('/login');

  /// Navigate to register page
  void goToRegister() => go('/register');

  /// Navigate to forgot password page
  void goToForgotPassword() => go('/forgot-password');

  /// Navigate to tasks page
  void goToTasks() => go('/tasks');

  /// Navigate to vault page
  void goToVault() => go('/accounts');

  /// Navigate to cashcard page
  void goToCashcard() => go('/cashcard');

  /// Navigate to profile page
  void goToProfile() => go('/profile');
}
