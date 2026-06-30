import 'package:flutter/foundation.dart';
import '../../data/repository/profile_repository.dart';
import '../../../../core/utils/app_exceptions.dart';

/// Provider that manages the profile screen state and business logic.
///
/// Why this exists:
/// - Manages profile data: loading, data, error.
/// - Delegates API calls to ProfileRepository.
/// - In a backend project, this is like a controller for the user profile.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  // ── State ───────────────────────────────────────────────────

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Actions ─────────────────────────────────────────────────

  /// Loads the profile for a given user ID.
  Future<void> loadProfile(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile(userId);
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load profile.';
      notifyListeners();
    }
  }
}
