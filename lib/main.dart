import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    // Firebase initialization failed, app will work in offline mode
    print('Firebase initialization failed: $e');
    print('Stack trace: $stackTrace');
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(const RankedApp());
}

class RankedApp extends StatelessWidget {
  const RankedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create forui theme
    final theme = FThemes.zinc.light;
    final darkTheme = FThemes.zinc.dark;

    return MaterialApp(
      title: '🏆 Ranked',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: Colors.black,
          error: Colors.white70,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w300, letterSpacing: -0.25, color: Colors.white),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w300, letterSpacing: 0, color: Colors.white),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0, color: Colors.white),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: Colors.white),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white70),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.white60),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shadowColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withOpacity(0.1),
          thickness: 1,
        ),
      ),
      // Wrap with forui theme
      builder: (context, child) {
        return FTheme(
          data: Theme.of(context).brightness == Brightness.light
              ? theme
              : darkTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
