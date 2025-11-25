# Copilot instructions for this repository

Short, actionable guidance for AI agents working on this Flutter monorepo.

Project overview
- **Multi-package Flutter repo** with three main packages at the repository root:
  - `admin_app/` — Admin/Kitchen app (Flutter).
  - `client_app/` — Client ordering app (Flutter).
  - `shared_logic/` — Local Dart package with models and services used by both apps.

Key architecture & patterns
- **Single shared service layer**: both apps depend on `shared_logic` via a path dependency declared in each app's `pubspec.yaml`.
  - Service entrypoint: `shared_logic/lib/services/order_repository.dart` (in-memory data, exposes Streams and CRUD-style futures).
  - Models live under `shared_logic/lib/models/` (e.g., `Product`, `Order`).
- **State management**: `provider` + `ChangeNotifier` viewmodels.
  - Each app wires DI in `main.dart` using `MultiProvider` and registers an `OrderRepository` instance plus app-specific viewmodels (see `client_app/lib/main.dart` and `admin_app/lib/main.dart`).
  - ViewModels are placed in `*/lib/viewmodels/` and UI in `*/lib/views/`.
- **Data flows**: UI -> ViewModel -> `OrderRepository`.
  - `OrderRepository` exposes `watchProducts()`, `watchOrders()` streams the viewmodels subscribe to.
  - Creating/updating orders is done via repository methods (e.g., `createOrder`, `updateOrderStatus`).

Developer workflows (concrete commands)
- Install deps (per-package):
  - `cd client_app && flutter pub get`
  - `cd admin_app && flutter pub get`
  - `cd shared_logic && flutter pub get`
- Run app on a device/emulator (from package folder):
  - `cd client_app && flutter run -d <device-id>`
  - `cd admin_app && flutter run -d <device-id>`
- Build release artifacts:
  - Android APK: `cd client_app && flutter build apk`
  - iOS: `cd client_app && flutter build ios` (use macOS host and follow CocoaPods steps in `ios/` when required)
- Tests:
  - `cd client_app && flutter test`
  - `cd admin_app && flutter test`
  - `cd shared_logic && flutter test`

Project-specific conventions
- **Path dependency for shared code**: keep `shared_logic` as a path dependency rather than publishing. When changing `shared_logic`, run `flutter pub get` in apps.
- **Provider wiring**: apps instantiate a single `OrderRepository()` in `main.dart` and pass it to viewmodels via `Provider<OrderRepository>.value(...)`. Follow this pattern for other cross-cutting services.
- **ViewModel names & locations**: viewmodels live at `lib/viewmodels/<*_view_model>.dart` and are constructors that accept `OrderRepository`. Example: `client_app/lib/viewmodels/cart_view_model.dart`.
- **Streams over polling**: prefer repository streams (e.g., `watchOrders`, `watchProducts`) for UI updates rather than polling repository methods.

Integration points & external dependencies
- `shared_logic` is the integration hub — changes here affect both apps. Keep its public API stable (models, stream signatures, repository methods).
- Native platform folders exist under each app (`android/`, `ios/`) for platform-specific code. Typical Flutter workflow applies — modify native files only when required.

When editing or adding features
- If you add a new shared service, put it in `shared_logic/lib/services/` and export it from the package. Update both apps' `pubspec.yaml` path dependency if you move the package.
- For new app-level state, add a `ChangeNotifier` in `lib/viewmodels/` and register it in `main.dart` following the MultiProvider pattern.

Examples (where to look)
- Provider DI: `client_app/lib/main.dart`, `admin_app/lib/main.dart`.
- Core shared service: `shared_logic/lib/services/order_repository.dart` (streams, sample data, CRUD methods).
- Models: `shared_logic/lib/models/` (product, order definitions used across apps).

Notes for the agent
- Preserve the `shared_logic` public API when refactoring; prefer non-breaking changes.
- Run `flutter pub get` in the package you're editing before running or testing.
- Use repository streams for UI updates; look for methods named `watch*` in `OrderRepository`.

If anything in this file looks incomplete or you want deeper examples (small code edits, tests, or run scripts), tell me which area to expand. 
