import 'dart:io' show Platform;

class AppConfig {
  // We're using only one API endpoint as specified
  static const String _apiBaseUrl = 'http://localhost:8080/api';
  
  // Base URL for API - simply return the hardcoded API URL
  static String get apiBaseUrl {
    return _apiBaseUrl;
  }
  
  // Method to log the current configuration
  static void logConfig() {
    print('🌐 API Base URL: $apiBaseUrl');
    print('📱 Platform: ${Platform.operatingSystem}');
  }
}
