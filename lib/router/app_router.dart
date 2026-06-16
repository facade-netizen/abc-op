// router/go_router.dart - Complete rewritten version with proper URL handling

import 'package:web/web.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bloc/authBlocs/user_changed_bloc.dart';
import '../localDb/token/login_token_box.dart';
import '../screens/dashboard_screen.dart';

import 'auth_notifier.dart';
import 'route_paths.dart';

/// Main router configuration for the application
/// Handles authentication, authorization, and navigation
class AppRouter {
  /// Creates and configures the GoRouter instance with authentication handling
  static GoRouter createRouter(UserAuthChangesBloc authBloc) {
    // Configure URL strategy for web platform
    _configureWebUrlStrategy();

    // Create authentication notifier for reactive auth state changes
    final authNotifier = AuthNotifier(authBloc);

    return GoRouter(
      // Initial route when app starts
      initialLocation: RoutePaths.login,

      // Enable debug logging for development
      debugLogDiagnostics: true,

      // Listen to auth state changes for automatic redirects
      refreshListenable: authNotifier,

      // Define all routes in the application
      routes: _buildRoutes(authBloc),

      // Handle authentication and authorization redirects
      redirect: (context, state) => _handleRedirect(context, state, authBloc),

      // Custom error page for 404 and routing errors
      errorBuilder: (context, state) => _buildErrorPage(context, state),
    );
  }

  /// Configures URL strategy for web platform
  /// Ensures clean URLs without hash fragments
  static void _configureWebUrlStrategy() {
    if (kIsWeb) {
      // Enable proper URL reflection for imperative navigation
      GoRouter.optionURLReflectsImperativeAPIs = true;

      // Ensure clean URL structure on initial load
      _setupCleanUrlStrategy();
    }
  }

  /// Sets up clean URL strategy by removing any hash fragments
  static void _setupCleanUrlStrategy() {
    final currentUrl = html.window.location.href;

    // If URL contains hash, clean it up
    if (currentUrl.contains('#')) {
      final cleanUrl = currentUrl.split('#').first;
      html.window.history.replaceState(null, '', cleanUrl);
    }
  }

  /// Builds all application routes including public, auth, and shell routes
  static List<RouteBase> _buildRoutes(UserAuthChangesBloc authBloc) {
    return [
      ...RoutePaths.routeConfigs.where((config) => config.isPublic).map(_createGoRoute),
      _buildProtectedShellRoute(authBloc),
    ];
  }

  static GoRoute _createGoRoute(RouteConfig config) {
    return GoRoute(
      path: config.path,
      name: config.name,
      builder: config.builder,
      pageBuilder: (context, state) {
        if (kIsWeb) {
          html.document.title = config.getTitle(state);
        }

        return NoTransitionPage(
          key: state.pageKey,
          child: config.builder(context, state),
        );
      },
    );
  }

  /// Builds the protected shell route that wraps all authenticated pages
  static ShellRoute _buildProtectedShellRoute(UserAuthChangesBloc authBloc) {
    return ShellRoute(
      // Builder for the shell wrapper (DashboardScreen)
      builder: (context, state, child) {
        final authState = authBloc.state;
        final savedUserData = authState is UserAuthChangesSuccess ? authState.savedData : null;

        return DashboardScreen(
          key: const ValueKey('dashboard_shell'),
          currentLocation: Uri.parse(state.location).path,
          savedUserData: savedUserData,
          child: child,
        );
      },

      // Nested routes under the shell
      routes: RoutePaths.routeConfigs.where((config) => !config.isPublic).map(_createGoRoute).toList(),
    );
  }

  /// Handles authentication and authorization redirect logic
  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
    UserAuthChangesBloc authBloc,
  ) async {
    // Get current location info from the raw request path
    final String currentLocation = Uri.parse(state.location).path;

    //Check reset password FIRST - before ANY authentication checks
    // Allow reset password route without full authentication check
    // This must come before checking authentication status
    final bool isOnResetPassword = currentLocation.startsWith('/reset-password');
    if (isOnResetPassword) {
      return null; // Allow navigation to reset password screen
    }

    // Get authentication data (only after reset password check)
    final savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
    final authState = authBloc.state;

    // Check authentication status
    final bool tokenExists = savedData != null && savedData.token != null;
    final bool isAuthenticated = authState is UserAuthChangesSuccess || tokenExists;

    final bool isOnLogin = currentLocation == RoutePaths.login;
    final bool isOnUnauthorized = currentLocation == RoutePaths.unauthorized;
    final bool isOnDashboardRoot = currentLocation == RoutePaths.manage;

    // Don't redirect during authentication progress
    if (authState is UserAuthChangesProgress) {
      return null;
    }

    // Enforce logout across tabs if a cross-tab logout signal exists
    if (kIsWeb && html.window.localStorage.getItem('app_logout') != null) {
      return isOnLogin ? null : RoutePaths.login;
    }

    // Handle unauthenticated users
    if (!isAuthenticated) {
      return isOnLogin ? null : RoutePaths.login;
    }

    // Check user permissions for authenticated users
    final String role = _extractUserRole(authState, savedData);
    final bool hasPermission = _checkUserPermission(role);

    // Redirect unauthorized users
    if (!hasPermission) {
      return isOnUnauthorized ? null : RoutePaths.unauthorized;
    }

    // Handle authenticated and authorized users
    if (isOnLogin || isOnUnauthorized) {
      return RoutePaths.manage;
    }
    if (isOnDashboardRoot) {
      return null;
    }

    // Allow navigation to current location
    return null;
  }

  /// Extracts user role from auth state or saved data
  static String _extractUserRole(
    UserAuthChangesState authState,
    dynamic savedData,
  ) {
    if (authState is UserAuthChangesSuccess) {
      return authState.savedData?.role ?? savedData?.role ?? '';
    }
    return savedData?.role ?? '';
  }

  /// Checks if user has required permissions based on role
  static bool _checkUserPermission(String role) {
    return role.toLowerCase().contains('opmanager');
  }

  /// Builds custom error page for 404 and routing errors
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    final String currentPath = Uri.parse(state.location).path;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFB5B5B5)),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        color: const Color(0xFF32416D),
                        child: const Text(
                          'HTTP Status 404 - Not Found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildErrorDetailRow('Type', 'Status Report'),
                            const SizedBox(height: 16),
                            _buildErrorDetailRow('Message', currentPath),
                            const SizedBox(height: 16),
                            _buildErrorDetailRow(
                              'Description',
                              'The origin server did not find a current representation for the target resource or is not willing to disclose that one exists.',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                          color: Color(0xFFF2F2F2),
                        ),
                        child: const Text(
                          'Apache Tomcat',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5B5B5B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildErrorDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5D6D84),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF252525),
          ),
        ),
      ],
    );
  }
}

// Export a convenient function to create the router
GoRouter createAppRouter(UserAuthChangesBloc authBloc) {
  return AppRouter.createRouter(authBloc);
}
