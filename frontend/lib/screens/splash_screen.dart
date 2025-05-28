import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auth_service.dart';
import '../utils/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {  bool _hasConnectivity = true;
  String _statusMessage = "Loading...";
  bool _hasError = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivityAndInit();
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((results) {
          _updateConnectionStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
        });
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
    Future<void> _checkConnectivityAndInit() async {
    // Log application config
    AppConfig.logConfig();
    
    try {
      // Check connectivity first
      final connectivityResults = await Connectivity().checkConnectivity();
      _updateConnectionStatus(
        connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none
      );
      
      if (!_hasConnectivity) {
        setState(() {
          _statusMessage = "No internet connection. Please check your settings.";
          _hasError = true;
        });
        return;
      }
      
      // Show splash screen for a minimum time
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // Attempt to initialize services
      await _navigateBasedOnAuth();
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = "Error initializing app: ${e.toString().split('\n').first}";
        _hasError = true;
      });
      print("💥 Startup error: $e");
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;
    
    setState(() {
      _hasConnectivity = result != ConnectivityResult.none;
      if (!_hasConnectivity) {
        _statusMessage = "No internet connection";
        _hasError = true;
      }
    });
  }

  Future<void> _retryConnection() async {
    setState(() {
      _statusMessage = "Checking connection...";
      _hasError = false;
    });
    
    await _checkConnectivityAndInit();
  }

  Future<void> _navigateBasedOnAuth() async {
    if (!mounted) return;
    
    setState(() {
      _statusMessage = "Authenticating...";
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // If we're still loading, wait a bit more
    if (authService.isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (!mounted) return;
    
    try {
      // Try to verify authentication status
      await authService.checkAuthStatus();
      
      if (!mounted) return;
      
      if (authService.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error connecting to server. Please check your network.";
        _hasError = true;
      });
      print("🔑 Auth service error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.balance,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Vakeel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Personal Legal Assistant',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _hasError
                ? ElevatedButton(
                    onPressed: _retryConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Retry'),
                  )
                : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}