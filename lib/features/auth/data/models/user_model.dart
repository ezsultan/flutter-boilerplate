import 'dart:convert';
import '../../domain/user.dart';

/// JSON serialization model for User data.
///
/// Why this exists:
/// - Separates JSON serialization logic from the domain model.
/// - The domain [User] class is pure Dart with no serialization concerns.
/// - This model handles the conversion between JSON (from API) and domain objects.
/// - In a backend project, this is like a DTO or a serializer.
///
/// Usage:
/// - AuthRemoteDatasource parses API JSON responses into UserModel.
/// - AuthRepository converts UserModel to User before returning to Provider.
class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  /// Creates a UserModel from a JSON map (API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }

  /// Converts to a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
    };
  }

  /// Converts to a JSON string for Hive storage.
  String toJsonString() => jsonEncode(toJson());

  /// Creates a UserModel from a JSON string (from Hive storage).
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Converts to the domain model.
  User toDomain() {
    return User(
      id: id,
      name: name,
      username: username,
      email: email,
    );
  }
}
