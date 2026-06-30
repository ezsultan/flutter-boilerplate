# Flutter Boilerplate

A Flutter boilerplate project designed for backend engineers who want an architecture that feels familiar.

## Architecture Overview

```
Controller (Page) [ConsumerWidget]
     ↓
Notifier (Business Logic) [Riverpod Notifier]
     ↓
Repository
     ↓
Datasource
     ↓
Dio (HTTP Client)
```

This architecture mirrors a typical backend stack:

| Backend (NestJS/Express) | Flutter (This Project) |
|--------------------------|----------------------|
| Controller               | Page (ConsumerWidget) |
| Service                  | Notifier (Riverpod)  |
| Repository               | Repository           |
| Data Access Object (DAO) | Datasource           |
| HTTP Client (Axios)      | Dio                  |
| Database (MongoDB/Postgres) | Hive + SecureStorage |
| DI Container             | Riverpod Providers   |

## Tool Versions

| Tool          | Version         |
|---------------|-----------------|
| Flutter       | 3.19.3 (stable) |
| Dart          | 3.3.1           |
| DevTools      | 2.31.1          |
| Java          | 1.8.0_461       |
| Kotlin        | 1.9.22          |
| Android Gradle Plugin | 8.2.2  |
| Gradle        | 8.7             |
| NDK           | 25.1.8937393    |
| compileSdk    | flutter.compileSdkVersion (34) |
| targetSdk     | flutter.targetSdkVersion (34) |
| minSdk        | flutter.minSdkVersion (21) |
| Java Compatibility | VERSION_17 (source & target) |
| Kotlin JVM Target | 17           |

## Dependencies

| Package                 | Version       | Purpose                              |
|-------------------------|---------------|--------------------------------------|
| flutter_riverpod        | ^2.5.1        | State management (Notifier pattern)  |
| dio                     | ^5.4.0        | HTTP client with interceptors        |
| hive                    | ^2.2.3        | Local NoSQL database                 |
| hive_flutter            | ^1.1.0        | Flutter-specific Hive initialization |
| flutter_secure_storage  | ^9.0.0        | Encrypted token storage              |
| go_router               | ^13.0.1       | Declarative routing with auth guards |
| connectivity_plus       | ^5.0.2        | Network status monitoring            |
| logger                  | ^2.0.2+1      | Request/response logging             |
| flutter_lints           | ^3.0.1        | Lint rules (dev dependency)          |

## Project Structure

```
lib/
├── core/                          # Shared infrastructure layer
│   ├── constants/                 # App-wide constants (API URLs, storage keys)
│   ├── network/                   # HTTP client (Dio + interceptors)
│   ├── storage/                   # Local storage wrappers (Hive, SecureStorage)
│   ├── services/                  # Shared services (Connectivity)
│   ├── utils/                     # Utility classes (Exceptions)
│   ├── widgets/                   # Shared widgets (Loading, Error, Empty states)
│   ├── routes/                    # GoRouter configuration (Riverpod provider)
│   ├── theme/                     # Material theme
│   └── providers/                 # Centralized Riverpod provider definitions
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasource/        # Remote and local data sources
│   │   │   ├── repository/        # Auth repository
│   │   │   └── models/           # JSON serialization models
│   │   ├── domain/               # Pure domain models
│   │   └── presentation/
│   │       ├── pages/            # UI pages (Splash, Login)
│   │       ├── provider/         # Riverpod Notifier + State
│   │       └── widgets/          # Feature-specific widgets
│   ├── home/                     # Home (posts) feature
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   ├── repository/
│   │   │   └── models/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/            # Home, Detail
│   │       ├── provider/         # Riverpod Notifier + State
│   │       └── widgets/
│   └── profile/                  # Profile feature
│       ├── data/
│       │   ├── datasource/
│       │   └── repository/
│       └── presentation/
│           ├── pages/
│           ├── provider/         # Riverpod Notifier + State
│           └── widgets/
├── shared/                        # Cross-feature shared code
│   └── widgets/                   # Shared widgets (Snackbar)
└── main.dart                      # Composition root (ProviderScope)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.19.3 (stable) or compatible
- Dart SDK 3.3.1 or compatible
- Java 17+ (for Android builds)
- Android Studio or VS Code with Flutter plugins

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd flutter-boilerplate

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Layer Breakdown

### 1. Core (`lib/core/`)

Contains everything shared across features.

#### `constants/`
- [`api_constants.dart`](lib/core/constants/api_constants.dart) — All API endpoint URLs
- [`app_constants.dart`](lib/core/constants/app_constants.dart) — Storage keys, timeouts, app metadata

#### `network/`
- [`api_client.dart`](lib/core/network/api_client.dart) — Dio wrapper with interceptors for:
  - Auth (Bearer token injection)
  - Error mapping (HTTP status → typed exceptions)
  - Logging
  - Auto-refresh on 401

#### `storage/`
- [`hive_service.dart`](lib/core/storage/hive_service.dart) — Singleton wrapper for Hive
- [`secure_storage_service.dart`](lib/core/storage/secure_storage_service.dart) — Wrapper for flutter_secure_storage

#### `services/`
- [`connectivity_service.dart`](lib/core/services/connectivity_service.dart) — Network status monitoring

#### `utils/`
- [`app_exceptions.dart`](lib/core/utils/app_exceptions.dart) — Typed exceptions (Unauthorized, ServerError, Timeout, etc.)

#### `widgets/`
- [`loading_widget.dart`](lib/core/widgets/loading_widget.dart) — Centered loading spinner
- [`error_widget.dart`](lib/core/widgets/error_widget.dart) — Error display with retry button
- [`empty_widget.dart`](lib/core/widgets/empty_widget.dart) — Empty state display

#### `routes/`
- [`app_router.dart`](lib/core/routes/app_router.dart) — GoRouter as a Riverpod `Provider<GoRouter>`, watches auth state reactively

#### `providers/`
- [`providers.dart`](lib/core/providers/providers.dart) — Centralized Riverpod provider definitions for all services, datasources, and repositories

### 2. Features (`lib/features/`)

Each feature follows the same structure:

#### `data/datasource/`
- Makes API calls or reads from storage
- Returns raw models (`UserModel`, `PostModel`)
- Throws `AppException` on errors

#### `data/repository/`
- Combines remote + local datasources
- Converts models → domain objects
- The Notifier only talks to this layer

#### `domain/`
- Pure Dart classes with no dependencies
- Business entities (`User`, `Post`)

#### `presentation/provider/`
- Defines an **immutable State class** with `copyWith`
- Defines a **Notifier** extending `Notifier<State>`
- Contains business logic
- Calls Repository methods
- Manages state (loading, error, data)
- Exposed as a `NotifierProvider`

#### `presentation/pages/`
- `ConsumerWidget` or `ConsumerStatefulWidget`
- Watches providers via `ref.watch()`
- Delegates user actions via `ref.read(provider.notifier).method()`
- No business logic here

### 3. State Management Pattern (Riverpod)

This project uses **Riverpod's Notifier pattern** instead of the classic ChangeNotifier pattern.

**Why Riverpod over Provider:**
- **Immutable state** — Each state change creates a new instance, preventing stale/mutated state bugs
- **Compile-safe** — No runtime errors from missing providers in the widget tree
- **No BuildContext needed** — Providers can be read anywhere, not just in widgets
- **Automatic disposal** — Providers are disposed when no longer watched
- **Testable** — Providers can be overridden easily in tests

**Pattern per feature:**

```dart
// 1. Immutable state class
class HomeState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  const HomeState({...});
  HomeState copyWith({...});
}

// 2. Notifier with business logic
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true);
    // ... call repository ...
    state = HomeState(posts: posts);
  }
}

// 3. Provider
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

// 4. UI (ConsumerWidget)
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    // ... render based on state ...
  }
}
```

### 4. Dependency Injection (Riverpod)

All dependencies are wired through Riverpod providers in [`lib/core/providers/providers.dart`](lib/core/providers/providers.dart):

```dart
// Service provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Datasource provider (depends on ApiClient)
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.watch(apiClientProvider));
});

// Repository provider (depends on datasources)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    localDatasource: ref.watch(authLocalDatasourceProvider),
  );
});
```

This mirrors backend DI containers (NestJS, Spring) where services are registered and resolved automatically. No manual `ChangeNotifierProvider` wrapping in the widget tree — just declare what each provider needs and Riverpod handles the rest.

### 5. Authentication Flow

```
App Launch
    ↓
SplashPage shown
    ↓
AuthNotifier.build() → _tryAutoLogin()
    ↓
┌─────────────────────────────┐
│ Token exists?               │
├─────────────────────────────┤
│ YES → Load cached user      │
│     → GoRouter redirects    │
│       to /home              │
├─────────────────────────────┤
│ NO → GoRouter redirects     │
│      to /login              │
└─────────────────────────────┘

Login Flow:
LoginPage → ref.read(authProvider.notifier).login(email, password)
    → AuthRepository.login()
      → AuthRemoteDatasource.login() (API call)
      → AuthLocalDatasource.saveTokens() (Secure Storage)
      → AuthLocalDatasource.saveUser() (Hive)
    → Notifier updates state → UI rebuilds
    → GoRouter redirects to /home

Token Refresh (Automatic):
ApiClient gets 401 response
    ↓
Auth interceptor catches it
    ↓
Gets refresh token from SecureStorage
    ↓
Calls refresh endpoint
    ↓
Saves new access token
    ↓
Retries the original request
    ↓
If refresh fails → throws UnauthorizedException → triggers logout
```

### 6. Data Flow (GET Posts Example)

```
HomePage (ConsumerWidget)
    ↓ ref.watch(homeProvider)
HomeNotifier.loadPosts()
    ↓ reads
PostRepository.getPosts()
    ↓ calls
PostRemoteDatasource.getPosts()
    ↓ calls
ApiClient.get('/posts')
    ↓
Dio makes HTTP request
    ↓
Response → PostModel.fromJson()
    ↓
PostModel → Post (domain)
    ↓
Notifier updates state → new HomeState(posts: posts)
    ↓
UI rebuilds with new data
```

## Key Principles

1. **Single Responsibility** — Every file has one clear purpose.
2. **Constructor Injection** — All dependencies are passed via constructors (no GetIt). Riverpod providers wire them together.
3. **Layer Separation** — Pages never call API directly. Notifiers never render UI. Datasources never contain business logic.
4. **Immutable State** — State classes are immutable with `copyWith`. No mutable ChangeNotifier properties.
5. **Typed Exceptions** — HTTP errors are mapped to meaningful Dart exceptions.
6. **No Code Generation** — Everything is written manually for clarity.
7. **Functional Over Beautiful** — Default Material widgets, no animations, no custom styling.

## Error Handling

All API errors are caught and mapped in the [`ApiClient`](lib/core/network/api_client.dart):

| HTTP Status | Exception | User Message |
|-------------|-----------|--------------|
| 401 | UnauthorizedException | "Session expired." |
| 403 | ForbiddenException | "No permission." |
| 404 | NotFoundException | "Resource not found." |
| 500 | ServerException | "Server error." |
| Timeout | TimeoutException | "Request timed out." |
| Network | NetworkException | "No internet." |
| Other | UnknownException | "Unexpected error." |

## Routes

| Path | Page | Auth Required |
|------|------|---------------|
| `/splash` | [SplashPage](lib/features/auth/presentation/pages/splash_page.dart) | No |
| `/login` | [LoginPage](lib/features/auth/presentation/pages/login_page.dart) | No |
| `/home` | [HomePage](lib/features/home/presentation/pages/home_page.dart) | Yes |
| `/detail/:id` | [DetailPage](lib/features/home/presentation/pages/detail_page.dart) | Yes |
| `/profile` | [ProfilePage](lib/features/profile/presentation/pages/profile_page.dart) | Yes |

The router is defined as a Riverpod `Provider<GoRouter>` in [`AppRouter.provider`](lib/core/routes/app_router.dart:36), which watches `authProvider` so the redirect guard stays reactive.

## Dummy API

This project uses JSONPlaceholder (`https://jsonplaceholder.typicode.com`) as a dummy API:

- Login is mocked (fetches user 1 from API, generates fake tokens)
- Posts are loaded from `/posts`
- Post details from `/posts/:id`
- User profile from `/users/:id`

## .gitignore

The following files and directories are excluded from version control via [`.gitignore`](.gitignore):

| Pattern | Description |
|---------|-------------|
| `*.class` | Compiled Java bytecode |
| `*.log` | Log files |
| `*.pyc` | Python compiled files |
| `*.swp` | Vim swap files |
| `.DS_Store` | macOS directory metadata |
| `.atom/` | Atom editor settings |
| `.buildlog/` | Build logs |
| `.history` | Shell history |
| `.svn/` | SVN version control |
| `.idea/` | IntelliJ/Android Studio IDE settings |
| `*.iml`, `*.ipr`, `*.iws` | IntelliJ module files |
| `.vscode/` | VS Code settings (commented out by default) |
| `**/doc/api/` | Generated API documentation |
| `**/ios/Flutter/.last_build_id` | iOS build cache |
| `.dart_tool/` | Dart tooling cache |
| `.flutter-plugins` | Auto-generated Flutter plugins list |
| `.flutter-plugins-dependencies` | Auto-generated plugin dependencies |
| `.pub-cache/` | Pub cache |
| `.pub/` | Pub staging directory |
| `/build/` | All build artifacts (Android, iOS, Flutter) |
| `app.*.symbols` | Symbolication files |
| `app.*.map.json` | Obfuscation mapping files |
| `/android/app/debug` | Android debug APK output |
| `/android/app/profile` | Android profile APK output |
| `/android/app/release` | Android release APK output |
