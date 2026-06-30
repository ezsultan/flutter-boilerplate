/// API endpoint constants.
///
/// Why this exists:
/// - Centralizes all API URLs so changing the base URL or adding endpoints
///   doesn't require searching through the entire codebase.
/// - In a backend project, this is like your routes/controllers configuration.
class ApiConstants {
  ApiConstants._();

  /// Base URL for JSONPlaceholder API (dummy data).
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Posts endpoints
  static const String posts = '/posts';
  static String postById(int id) => '/posts/$id';

  /// Users endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';

  /// Mock auth endpoints (JSONPlaceholder doesn't have auth, so we simulate it).
  static const String login = '/auth/login'; // Mocked locally
  static const String refresh = '/auth/refresh'; // Mocked locally
}
