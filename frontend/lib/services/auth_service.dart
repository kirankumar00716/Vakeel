import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import './api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthService() {
    _checkLoginStatus();
  }
  // Check if user is logged in by verifying token exists
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _getCurrentUser();
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      print('🔑 Auth check failed: $e');
      _isLoggedIn = false;
      _errorMessage = 'Session expired. Please login again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Public method to check authentication status
  // Used by the splash screen to verify connectivity and auth status
  Future<bool> checkAuthStatus() async {
    _errorMessage = null;
    
    try {
      final token = await _storage.read(key: 'access_token');
      
      if (token == null) {
        _isLoggedIn = false;
        return false;
      }
      
      // Test the API connection by getting user data
      await _getCurrentUser();
      _isLoggedIn = true;
      return true;
    } catch (e) {
      print('🔑 Auth check failed: $e');
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.receiveTimeout) {
          _errorMessage = 'Cannot connect to server. Please check your internet connection.';
        } else if (e.response?.statusCode == 401) {
          _errorMessage = 'Session expired. Please login again.';
          await _storage.delete(key: 'access_token');
        } else {
          _errorMessage = 'Server error: ${e.response?.statusCode ?? "Unknown"}';
        }
      } else {
        _errorMessage = 'Connection error: ${e.toString().split('\n').first}';
      }
      
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  // Register a new user
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.post('/register', {
        'username': username,
        'email': email,
        'password': password,
      });
      
      // Auto login after registration
      return await login(username, password);
    } catch (e) {
      if (e is DioException) {
        _errorMessage = e.response?.data['detail'] ?? 'Registration failed';
      } else {
        _errorMessage = 'An error occurred during registration';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('Attempting login with API URL: ${_apiService.baseUrl}');
      
      // Create form data for token request
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });
        
      // Use Dio directly to avoid token interceptor
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      print('Sending login request to: ${_apiService.baseUrl}/token');
      
      final response = await dio.post(
        '${_apiService.baseUrl}/token',
        data: formData,
      );
      
      print('Login response received: ${response.statusCode}');
      
      final token = response.data['access_token'];
      await _storage.write(key: 'access_token', value: token);
      
      await _getCurrentUser();
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;    } catch (e) {
      print('Login error: $e');
      
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.sendTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          _errorMessage = 'Connection timeout. Server might be unreachable.';
        } else if (e.type == DioExceptionType.connectionError) {
          _errorMessage = 'Cannot connect to server. Please check if the backend is running.';
        } else if (e.response != null) {
          _errorMessage = 'Server error (${e.response!.statusCode}): ${e.response?.data['detail'] ?? 'Login failed'}';
        } else {
          _errorMessage = 'Network error: ${e.message}';
        }
      } else {
        _errorMessage = 'An error occurred during login: ${e.toString()}';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  // Get current user profile
  Future<void> _getCurrentUser() async {
    try {
      final userData = await _apiService.get('/me');
      _currentUser = userData;
      _errorMessage = null;
    } catch (e) {
      _currentUser = null;
      if (e is DioException && e.response?.statusCode == 401) {
        // Token expired or invalid
        await _storage.delete(key: 'access_token');
        _isLoggedIn = false;
        _errorMessage = 'Session expired. Please login again.';
      } else {
        _errorMessage = 'Failed to load user profile';
      }
    }
    notifyListeners();
  }
}