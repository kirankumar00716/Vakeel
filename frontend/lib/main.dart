import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakeel/screens/splash_screen.dart';
import 'package:vakeel/screens/login_screen.dart';
import 'package:vakeel/screens/register_screen.dart';
import 'package:vakeel/screens/home_screen.dart';
import 'package:vakeel/services/auth_service.dart';
import 'package:vakeel/services/legal_service.dart';
import 'package:vakeel/utils/config.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup error handling for uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('❌ Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
    // You could log errors to a service here
  };
  
  // Log app configuration
  try {
    AppConfig.logConfig();
  } catch (e) {
    print('⚠️ Failed to log configuration: $e');
  }
  
  // Run the app with error handling
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LegalService()),
      ],
      child: MaterialApp(
        title: 'Vakeel - Your Legal Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.indigo,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.indigo,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}