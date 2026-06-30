import 'package:go_router/go_router.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Application route definitions using GoRouter.
///
/// Why this exists:
/// - Centralizes all routing logic in one place.
/// - Supports redirect guards for authentication.
/// - In a backend project, this is like your router configuration or middleware stack.
///
/// Route flow:
/// /splash -> checks auth state
///   ├─ authenticated -> /home
///   └─ unauthenticated -> /login
/// /home -> /detail/:id
/// /profile
///
/// Auth guard:
/// - Before navigating to any protected route, the router checks if the user
///   is authenticated. If not, it redirects to /login.
class AppRouter {
  AppRouter._();

  /// Creates the GoRouter instance with all route definitions.
  ///
  /// Takes an [authRepository] so the router can check auth state directly
  /// without depending on a Provider (which requires a BuildContext).
  static GoRouter createRouter(AuthRepository authRepository) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        return _authGuard(authRepository, state);
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/detail/:id',
          name: 'detail',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return DetailPage(postId: id);
          },
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }

  /// Auth guard that redirects unauthenticated users to /login.
  ///
  /// Why this exists:
  /// - Protects routes from being accessed without authentication.
  /// - Automatically runs on every navigation.
  /// - In a backend project, this is like a middleware or guard.
  static String? _authGuard(AuthRepository authRepository, GoRouterState state) {
    final isLoggedIn = authRepository.isLoggedIn();
    final isAuthRoute = state.matchedLocation == '/login';
    final isSplashRoute = state.matchedLocation == '/splash';

    // Allow splash screen to load without redirecting.
    if (isSplashRoute) return null;

    // If not logged in and trying to access a protected route, redirect to login.
    if (!isLoggedIn && !isAuthRoute) return '/login';

    // If logged in and trying to access login, redirect to home.
    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  }
}
