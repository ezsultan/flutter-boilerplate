# Flutter Boilerplate

A Flutter boilerplate project designed for backend engineers who want an architecture that feels familiar.

## Architecture Overview

```
Controller (Page)
     ↓
Provider (Business Logic)
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
| Controller               | Page (UI)           |
| Service                  | Provider             |
| Repository               | Repository           |
| Data Access Object (DAO) | Datasource           |
| HTTP Client (Axios)      | Dio                  |
| Database (MongoDB/Postgres) | Hive + SecureStorage |

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
| provider                | ^6.1.1        | State management (ChangeNotifier)    |
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
│   ├── routes/                    # GoRouter configuration
│   └── theme/                     # Material theme
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasource/        # Remote and local data sources
│   │   │   ├── repository/        # Auth repository
│   │   │   └── models/           # JSON serialization models
│   │   ├── domain/               # Pure domain models
│   │   └── presentation/
│   │       ├── pages/            # UI pages (Splash, Login)
│   │       ├── provider/         # State management
│   │       └── widgets/          # Feature-specific widgets
│   ├── home/                     # Home (posts) feature
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   ├── repository/
│   │   │   └── models/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/            # Home, Detail
│   │       ├── provider/
│   │       └── widgets/
│   └── profile/                  # Profile feature
│       ├── data/
│       │   ├── datasource/
│       │   └── repository/
│       └── presentation/
│           ├── pages/
│           ├── provider/
│           └── widgets/
├── shared/                        # Cross-feature shared code
│   └── widgets/                   # Shared widgets (Snackbar)
└── main.dart                      # Composition root
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
- `api_constants.dart` — All API endpoint URLs
- `app_constants.dart` — Storage keys, timeouts, app metadata

#### `network/`
- `api_client.dart` — Dio wrapper with interceptors for:
  - Auth (Bearer token injection)
  - Error mapping (HTTP status → typed exceptions)
  - Logging
  - Auto-refresh on 401

#### `storage/`
- `hive_service.dart` — Singleton wrapper for Hive
- `secure_storage_service.dart` — Wrapper for flutter_secure_storage

#### `services/`
- `connectivity_service.dart` — Network status monitoring

#### `utils/`
- `app_exceptions.dart` — Typed exceptions (Unauthorized, ServerError, Timeout, etc.)

#### `widgets/`
- `loading_widget.dart` — Centered loading spinner
- `error_widget.dart` — Error display with retry button
- `empty_widget.dart` — Empty state display

#### `routes/`
- `app_router.dart` — GoRouter with auth redirect guard

### 2. Features (`lib/features/`)

Each feature follows the same structure:

#### `data/datasource/`
- Makes API calls or reads from storage
- Returns raw models (UserModel, PostModel)
- Throws AppException on errors

#### `data/repository/`
- Combines remote + local datasources
- Converts models → domain objects
- The Provider only talks to this layer

#### `domain/`
- Pure Dart classes with no dependencies
- Business entities (User, Post)

#### `presentation/provider/`
- Extends ChangeNotifier
- Contains business logic
- Calls Repository methods
- Manages state (loading, error, data)

#### `presentation/pages/`
- StatelessWidget or StatefulWidget
- Watches Provider for state changes
- Delegates user actions to Provider
- No business logic here

### 3. Authentication Flow

```
App Launch
    ↓
SplashPage shown
    ↓
AuthProvider.tryAutoLogin()
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
LoginPage → AuthProvider.login()
    → AuthRepository.login()
      → AuthRemoteDatasource.login() (API call)
      → AuthLocalDatasource.saveTokens() (Secure Storage)
      → AuthLocalDatasource.saveUser() (Hive)
    → Provider updates currentUser
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

### 4. Data Flow (GET Posts Example)

```
HomePage (UI)
    ↓ watches
HomeProvider.loadPosts()
    ↓ calls
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
Provider updates state
    ↓
UI rebuilds with new data
```

## Key Principles

1. **Single Responsibility** — Every file has one clear purpose.
2. **Constructor Injection** — All dependencies are passed via constructors (no GetIt).
3. **Layer Separation** — Pages never call API directly. Providers never render UI. Datasources never contain business logic.
4. **Typed Exceptions** — HTTP errors are mapped to meaningful Dart exceptions.
5. **No Code Generation** — Everything is written manually for clarity.
6. **Functional Over Beautiful** — Default Material widgets, no animations, no custom styling.

## Error Handling

All API errors are caught and mapped in the ApiClient:

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
| `/splash` | SplashPage | No |
| `/login` | LoginPage | No |
| `/home` | HomePage | Yes |
| `/detail/:id` | DetailPage | Yes |
| `/profile` | ProfilePage | Yes |

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
