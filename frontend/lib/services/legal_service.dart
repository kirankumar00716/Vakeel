import 'dart:async';
import 'package:flutter/foundation.dart';
import './api_service.dart';
import '../models/legal_query.dart';

class LegalService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  LegalQuery? _currentQuery;
  List<LegalQuery> _queryHistory = [];
  List<LegalQuery> _savedQueries = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LegalQuery? get currentQuery => _currentQuery;
  List<LegalQuery> get queryHistory => List.unmodifiable(_queryHistory);
  List<LegalQuery> get savedQueries => List.unmodifiable(_savedQueries);

  // Submit a new legal query
  Future<bool> submitQuery(String query, {String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post('/legal/query', {
        'query': query,
        'category': category,
      });
      
      final newQuery = LegalQuery.fromJson(response);
      _currentQuery = newQuery;
      
      // Add to history and refresh history list
      _queryHistory.insert(0, newQuery);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to process legal query';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch query history
  Future<void> fetchQueryHistory({int skip = 0, int limit = 20}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get(
        '/legal/history',
        queryParams: {'skip': skip, 'limit': limit},
      );
      
      _queryHistory = (response as List)
          .map((item) => LegalQuery.fromJson(item))
          .toList();
          
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch query history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch saved queries
  Future<void> fetchSavedQueries({int skip = 0, int limit = 20}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get(
        '/legal/saved',
        queryParams: {'skip': skip, 'limit': limit},
      );
      
      _savedQueries = (response as List)
          .map((item) => LegalQuery.fromJson(item))
          .toList();
          
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch saved queries';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle saved status for a query
  Future<bool> toggleSaveQuery(int queryId, bool isSaved) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.put(
        '/legal/$queryId',
        {'is_saved': isSaved},
      );
      
      final updated = LegalQuery.fromJson(response);
      
      // Update in current lists
      _updateQueryInLists(updated);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update query';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get query by ID
  Future<LegalQuery?> getQueryById(int queryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/legal/$queryId');
      final query = LegalQuery.fromJson(response);
      
      _currentQuery = query;
      _isLoading = false;
      notifyListeners();
      
      return query;
    } catch (e) {
      _errorMessage = 'Failed to fetch query details';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete a query
  Future<bool> deleteQuery(int queryId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.delete('/legal/$queryId');
      
      // Remove from lists
      _queryHistory.removeWhere((q) => q.id == queryId);
      _savedQueries.removeWhere((q) => q.id == queryId);
      
      if (_currentQuery?.id == queryId) {
        _currentQuery = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete query';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper method to update query in all lists
  void _updateQueryInLists(LegalQuery updated) {
    // Update in history
    int historyIndex = _queryHistory.indexWhere((q) => q.id == updated.id);
    if (historyIndex != -1) {
      _queryHistory[historyIndex] = updated;
    }
    
    // Update in saved queries
    int savedIndex = _savedQueries.indexWhere((q) => q.id == updated.id);
    if (updated.isSaved && savedIndex == -1) {
      _savedQueries.insert(0, updated);
    } else if (!updated.isSaved && savedIndex != -1) {
      _savedQueries.removeAt(savedIndex);
    } else if (updated.isSaved && savedIndex != -1) {
      _savedQueries[savedIndex] = updated;
    }
    
    // Update current query if it's the same
    if (_currentQuery?.id == updated.id) {
      _currentQuery = updated;
    }
  }
}