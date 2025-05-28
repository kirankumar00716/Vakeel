import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/legal_service.dart';
import '../widgets/legal_query_card.dart';
import '../models/legal_query.dart';

class QueryHistoryScreen extends StatefulWidget {
  final bool showSavedOnly;
  
  const QueryHistoryScreen({
    Key? key,
    required this.showSavedOnly,
  }) : super(key: key);

  @override
  State<QueryHistoryScreen> createState() => _QueryHistoryScreenState();
}

class _QueryHistoryScreenState extends State<QueryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadQueries();
  }
  
  Future<void> _loadQueries() async {
    final legalService = Provider.of<LegalService>(context, listen: false);
    if (widget.showSavedOnly) {
      await legalService.fetchSavedQueries();
    } else {
      await legalService.fetchQueryHistory();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showSavedOnly ? 'Saved Queries' : 'Query History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadQueries();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQueries,
        child: _buildQueryList(),
      ),
    );
  }
  
  Widget _buildQueryList() {
    final legalService = Provider.of<LegalService>(context);
    final queries = widget.showSavedOnly 
        ? legalService.savedQueries 
        : legalService.queryHistory;
    
    if (legalService.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (queries.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: queries.length,
      itemBuilder: (context, index) {
        final query = queries[index];
        
        return LegalQueryCard(
          query: query,
          onTap: () {
            _showQueryDetails(query.id);
          },
          onSaveToggle: () {
            legalService.toggleSaveQuery(query.id, !query.isSaved);
          },
          onDelete: () {
            _showDeleteConfirmation(query.id);
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.showSavedOnly ? Icons.bookmark_border : Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.showSavedOnly 
                ? 'No saved queries yet' 
                : 'No query history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.showSavedOnly 
                  ? 'Bookmark important queries to access them here'
                  : 'Ask legal questions to start building your history',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Go to query screen
              if (widget.showSavedOnly) {
                // Navigate to history tab
                final scaffold = Scaffold.of(context);
                scaffold.openDrawer(); // This is a hack to access the scaffold
              } else {
                // Navigate to query tab
              }
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Ask a question'),
          ),
        ],
      ),
    );
  }
  
  void _showQueryDetails(int queryId) async {
    final legalService = Provider.of<LegalService>(context, listen: false);
    final query = await legalService.getQueryById(queryId);
    
    if (query != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Query Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      LegalQueryCard(
                        query: query,
                        showFullResponse: true,
                        onSaveToggle: () {
                          legalService.toggleSaveQuery(query.id, !query.isSaved);
                          Navigator.pop(context);
                        },
                        onDelete: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(query.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
  
  void _showDeleteConfirmation(int queryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Query'),
          content: const Text('Are you sure you want to delete this query? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final legalService = Provider.of<LegalService>(context, listen: false);
                legalService.deleteQuery(queryId);
                Navigator.pop(context);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
}