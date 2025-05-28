import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/config.dart';

class ApiService {  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // We'll determine the appropriate base URL dynamically
  late final String baseUrl;  ApiService() {
    // Get the base URL from our configuration
    baseUrl = AppConfig.apiBaseUrl;
    
    // Add timeout to avoid hanging on network issues
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout on 401 Unauthorized
            // Not implemented for simplicity
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(
        '$baseUrl$endpoint',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete('$baseUrl$endpoint');
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  // Enhanced error handling
  void _handleError(DioException error) {
    String errorMessage = 'An error occurred';
    String errorType = 'Unknown';
    
    if (error.response != null) {
      // Server responded with an error status code
      errorType = 'Server Error (${error.response!.statusCode})';
      try {
        if (error.response!.data is Map) {
          errorMessage = error.response!.data['detail'] ?? errorMessage;
        } else if (error.response!.data is String) {
          errorMessage = error.response!.data;
        }
      } catch (e) {
        errorMessage = 'Failed to parse error response';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.sendTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      // Network timeout issues
      errorType = 'Network Timeout';
      errorMessage = 'Connection timed out. Please check your internet connection and server availability.';
    } else if (error.type == DioExceptionType.connectionError) {
      // Connection issues - common when using wrong IP or server is down
      errorType = 'Connection Failed';
      errorMessage = 'Could not connect to server at $baseUrl. Please check your internet connection.';
    } else {
      // Other Dio errors
      errorType = 'Network Error (${error.type})';
      errorMessage = error.message ?? 'An unknown network error occurred';
    }
    
    // Log detailed error information for debugging
    print('⚠️ API ERROR ($errorType): $errorMessage');
    print('📍 Request: ${error.requestOptions.method} ${error.requestOptions.path}');
    
    // In a production app, you might want to log this to a service or display a user-friendly message
  }
}