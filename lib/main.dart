import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/controllers/auth_controller.dart';
import 'package:vanh_store_app/provider/user_provider.dart';
import 'package:vanh_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:vanh_store_app/views/screens/main_screen.dart';

// Stripe Configuration - Move to environment variables in production
const String _stripePublishableKey =
    "pk_test_51Qw2Lx2M2fShhjelLc1OYwwNbFLVt0JdwPSoi3YxwB2OYIOw5nSkCEIO0atUePDiFQ75xBMTKmh8AgkpACSnQl2A00heKAdnDf";

void main() async {
  // Ensure Flutter is initialized before running async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Configure System UI
  _configureSystemUI();

  // Initialize Stripe
  await _initializeStripe();

  // Run app with Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

/// Configure system UI overlay style
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations (optional - remove if not needed)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Initialize Stripe payment SDK
Future<void> _initializeStripe() async {
  try {
    Stripe.publishableKey = _stripePublishableKey;
    await Stripe.instance.applySettings();
    debugPrint('Stripe initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Stripe: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vanh Store',
      theme: _buildAppTheme(),
      home: const AuthenticationWrapper(),
    );
  }

  /// Build custom app theme
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget to handle authentication state
class AuthenticationWrapper extends ConsumerStatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  ConsumerState<AuthenticationWrapper> createState() =>
      _AuthenticationWrapperState();
}

class _AuthenticationWrapperState
    extends ConsumerState<AuthenticationWrapper> {
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('auth-token');
      final refreshToken = preferences.getString('refresh-token');
      final userJson = preferences.getString('user');

      if (token != null && refreshToken != null && userJson != null) {
        // Set user in provider
        ref.read(userProvider.notifier).setUser(userJson);

        // Optional: Validate or refresh token on app start
        // This ensures the user has a valid session
        try {
          final authController = AuthController();
          await authController.refreshAccessToken();
        } catch (e) {
          debugPrint('Token refresh failed on startup: $e');
          // If refresh fails, clear tokens and sign out
          await preferences.remove('auth-token');
          await preferences.remove('refresh-token');
          await preferences.remove('user');
          ref.read(userProvider.notifier).signOut();
        }
      } else {
        // No valid session found
        ref.read(userProvider.notifier).signOut();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      ref.read(userProvider.notifier).signOut();
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _LoadingScreen();
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to initialize app'),
        ),
      );
    }

    // Watch user provider and navigate accordingly
    final user = ref.watch(userProvider);
    return user != null ? MainScreen() : LoginScreen();
  }
}

/// Custom loading screen with branding
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade700,
                  ],
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'Vanh Store',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
