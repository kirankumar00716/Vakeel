import 'dart:io' show Platform;

class AppConfig {
  // Using the network IP directly for all environments
  // This allows the app to connect from both emulators and physical devices
  static const String _apiBaseUrl = 'http://192.168.0.227:8080/api';
  
  // Base URL for API
  static String get apiBaseUrl {
    return _apiBaseUrl;
  }
  
  // Method to log the current configuration
  static void logConfig() {
    print('🌐 API Base URL: $apiBaseUrl');
    print('📱 Platform: ${Platform.operatingSystem}');
  }
}
