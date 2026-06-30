import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/datasource/auth_local_datasource.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/home/data/datasource/post_remote_datasource.dart';
import '../../features/home/data/repository/post_repository.dart';
import '../../features/profile/data/datasource/profile_remote_datasource.dart';
import '../../features/profile/data/repository/profile_repository.dart';
import '../network/api_client.dart';
import '../storage/hive_service.dart';

/// ── Infrastructure Providers ────────────────────────────────
///
/// These providers expose singleton services to the entire app.
/// HiveService must be initialized before runApp() and injected
/// via ProviderScope overrides (see main.dart).

/// ApiClient singleton — handles HTTP, auth tokens, and error mapping.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// HiveService — local storage wrapper. Injected via override in main.dart.
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError(
    'HiveService must be provided via ProviderScope overrides in main.dart',
  );
});

/// ── Auth Providers ──────────────────────────────────────────

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.watch(apiClientProvider));
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(hiveService: ref.watch(hiveServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    localDatasource: ref.watch(authLocalDatasourceProvider),
  );
});

/// ── Post / Home Providers ───────────────────────────────────

final postRemoteDatasourceProvider = Provider<PostRemoteDatasource>((ref) {
  return PostRemoteDatasource(apiClient: ref.watch(apiClientProvider));
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(remoteDatasource: ref.watch(postRemoteDatasourceProvider));
});

/// ── Profile Providers ───────────────────────────────────────

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(apiClient: ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(remoteDatasource: ref.watch(profileRemoteDatasourceProvider));
});
