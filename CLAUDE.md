# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter e-commerce mobile application (`vanh_store_app`) that connects to a Node.js backend API. The app allows users to browse products, manage shopping carts, place orders, and view order history.

## Development Commands

### Setup and Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# Clean build artifacts
flutter clean
```

### Running the Application
```bash
# Run on iOS simulator (connects to http://localhost:3000)
flutter run -d ios

# Run on Android emulator (connects to http://10.0.2.2:3000)
flutter run -d android

# Run with specific device
flutter run -d <device-id>
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Building
```bash
# Build for iOS
flutter build ios

# Build for Android
flutter build apk
flutter build appbundle
```

## Architecture

### State Management: Riverpod (Legacy)
The app uses `flutter_riverpod` with the legacy API (`StateNotifier` and `StateNotifierProvider`). All state is managed through providers located in `lib/provider/`:
- `user_provider.dart` - Authentication and user state
- `product_provider.dart` - Product listings
- `cart_provider.dart` - Shopping cart state
- `category_provider.dart` - Category data
- `banner_provider.dart` - Banner/promotion data
- `order_provider.dart` - Order history

**Important**: The codebase uses `flutter_riverpod/legacy.dart` imports. When working with providers, maintain this pattern.

### Application Flow
1. **App Initialization** (`main.dart`):
   - Wraps app in `ProviderScope`
   - Checks for stored auth token and user data in `SharedPreferences`
   - Routes to `LoginScreen` if unauthenticated, or `MainScreen` if authenticated

2. **Main Navigation** (`main_screen.dart`):
   - Bottom navigation with 6 tabs: Home, Favorites, Categories, Stores, Cart, Account
   - Uses indexed stack to switch between screens
   - Navigation state managed locally with `setState`

3. **Authentication Flow**:
   - User data persisted in `SharedPreferences` with keys: `auth-token` and `user`
   - Auth handled by `AuthController` in `lib/controllers/auth_controller.dart`
   - On successful login/signup, user data stored and `UserProvider` updated
   - Sign out clears both preferences and provider state

### API Integration

**Backend URL Configuration** (`global_variables.dart`):
- Android Emulator: `http://10.0.2.2:3000`
- iOS Simulator: `http://localhost:3000`
- Default fallback: `http://localhost:3000`

**HTTP Response Handling** (`services/manage_http_response.dart`):
- Centralized response handler `manageHttpResponse()` that checks status codes (200, 201, 400, 500)
- Shows snackbars for errors with messages from response body
- Executes `onSuccess` callback for successful responses

**Controllers** (`lib/controllers/`):
All API calls are made through controller classes:
- `auth_controller.dart` - Sign up, sign in, sign out, update user location
- `product_controller.dart` - Load popular products, products by category, product by ID
- `order_controller.dart` - Upload orders, load buyer orders, delete orders
- `product_review_controller.dart` - Product reviews
- `banner_controller.dart`, `category_controller.dart`, `subcategory_controller.dart` - Content management

Controllers use the `http` package and follow the pattern:
```dart
Future<void> operation() async {
  try {
    http.Response res = await http.post/get/put/delete(
      Uri.parse('$uri/api/endpoint'),
      body: jsonEncode(data),
      headers: {"Content-Type": "application/json;charset=UTF-8"},
    );
    manageHttpResponse(res: res, context: context, onSuccess: () {
      // Handle success
    });
  } catch (e) {
    debugPrint('Error: $e');
    showSnackBar(context, 'Error message');
  }
}
```

### Data Models (`lib/models/`)
Models use JSON serialization with `fromMap()` factories and `toMap()`/`toJson()` methods:
- `user.dart` - User authentication and profile
- `product.dart` - Product with `_id` mapping to `id` (MongoDB convention)
- `cart.dart` - Cart items (no JSON serialization, used only in provider)
- `order.dart` - Order details
- `banner.dart`, `category.dart`, `subcategory.dart` - Content models
- `product_review.dart` - Product ratings and reviews

**Key Pattern**: Backend uses MongoDB, so model `fromMap()` methods map `_id` field to `id` property.

### Cart Management
Cart is managed entirely in memory via `CartNotifier` (`provider/cart_provider.dart`):
- Keyed by `productId` in a `Map<String, Cart>`
- Operations: `addProductToCart()`, `IncrementQuantity()`, `DecrementQuantity()`, `removeProduct()`
- Cart persists only during app session (not saved to SharedPreferences or backend)
- When user places order, each cart item creates a separate order via `OrderController.uploadOrders()`

### UI Structure (`lib/views/`)
- `screens/authentication_screens/` - Login and registration
- `screens/main_screen.dart` - Bottom navigation container
- `screens/nav_screens/` - Main tab screens (home, cart, categories, etc.)
- `screens/nav_screens/widgets/` - Reusable widgets for nav screens
- `detail/screens/` - Detail views (product detail, order detail, checkout, etc.)
- `detail/screens/widgets/` - Reusable widgets for detail screens

### Styling
- Uses Google Fonts (`google_fonts` package)
- Custom assets in `assets/icons/` and `assets/images/`
- Material Design with purple theme (`ColorScheme.fromSeed(seedColor: Colors.deepPurple)`)

## Key Patterns and Conventions

### Adding New Features

**When adding a new data entity**:
1. Create model in `lib/models/` with `fromMap()` and `toMap()` methods
2. Create controller in `lib/controllers/` for API operations
3. Create provider in `lib/provider/` using `StateNotifier` pattern
4. Wire up UI to consume provider with `ConsumerWidget` or `Consumer`

**When adding a new screen**:
1. Place in appropriate `views/` subdirectory
2. If using provider state, extend `ConsumerWidget` or `ConsumerStatefulWidget`
3. For navigation, use `Navigator.push()` or `Navigator.pushAndRemoveUntil()`

### Error Handling
- Always wrap API calls in try-catch
- Use `manageHttpResponse()` for standard HTTP responses
- Show errors to users via `showSnackBar()`
- Log errors with `debugPrint()` for debugging

### Authentication
- Check authentication state: `ref.watch(userProvider)`
- Update user: `ref.read(userProvider.notifier).setUser(userJson)`
- Sign out: `ref.read(userProvider.notifier).signOut()`
- Remember to update both `SharedPreferences` and provider state

### Testing the Backend Connection
The app expects a backend server running on:
- `http://localhost:3000` (iOS)
- `http://10.0.2.2:3000` (Android)

Ensure the backend is running before testing the app, or modify `lib/global_variables.dart` to point to a different URL.
