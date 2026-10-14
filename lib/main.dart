import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/store_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bounded image cache to prevent CanvasKit GPU texture memory exhaustion
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      50 * 1024 * 1024; // 50 MB

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabaseAnonKey,
    );

    runApp(const NISDigitalStoreApp());
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrint(stackTrace.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Initialization Error:\n$e',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NISDigitalStoreApp extends StatelessWidget {
  const NISDigitalStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'NIS Digital Store',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(themeProvider.currentThemeId),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
