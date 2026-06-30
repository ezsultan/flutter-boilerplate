import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../../../../core/providers/providers.dart';

/// ── Profile State ───────────────────────────────────────────

/// Immutable state representation for the profile screen.
///
/// Why this exists:
/// - Replaces the mutable ChangeNotifier pattern with immutable state.
/// - Encapsulates all UI state for the profile: loading, data, error.
/// - The UI watches this state and renders accordingly.
class ProfileState {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? Function()? profile,
    bool? isLoading,
    String? Function()? error,
  }) {
    return ProfileState(
      profile: profile != null ? profile() : this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ── Profile Notifier ────────────────────────────────────────

/// Riverpod Notifier that manages the profile screen state and business logic.
///
/// Why this exists:
/// - Manages profile data: loading, data, error.
/// - Delegates API calls to ProfileRepository.
/// - In a backend project, this is like a controller for the user profile.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  /// Loads the profile for a given user ID.
  ///
  /// Flow:
  /// 1. Set loading state → UI shows spinner.
  /// 2. Call ProfileRepository.getProfile() → delegates to datasource.
  /// 3. On success: store profile data, clear error.
  /// 4. On failure: store error.
  Future<void> loadProfile(int userId) async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final profile = await profileRepository.getProfile(userId);
      state = ProfileState(profile: profile);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Failed to load profile.',
      );
    }
  }
}

/// ── Profile Provider ────────────────────────────────────────

/// The global Riverpod provider for profile screen state.
///
/// UI pages watch this provider to reactively rebuild when profile state changes.
/// UI pages call actions via `ref.read(profileProvider.notifier).loadProfile(id)`.
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
