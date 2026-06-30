/// Domain model for a User.
///
/// Why this exists:
/// - This is a pure Dart class with no framework dependencies.
/// - It represents the core business concept of a "User" in the domain layer.
/// - The UI and data layers depend on this model, not the other way around.
/// - In a backend project, this is like a domain entity in NestJS or a model in Mongoose.
///
/// Usage:
/// - AuthProvider exposes the current user to the UI.
/// - AuthRepository returns User objects to the Provider.
class User {
  final int id;
  final String name;
  final String username;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });
}
