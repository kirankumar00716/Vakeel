import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/legal_service.dart';
import '../models/legal_query.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({Key? key}) : super(key: key);

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _queryFocusNode = FocusNode();
  
  bool _isTyping = false;
  String? _selectedCategory;
  
  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }
  
  void _submitQuery() async {
    if (_queryController.text.trim().isEmpty) return;
    
    final legalService = Provider.of<LegalService>(context, listen: false);
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Submit the query
    await legalService.submitQuery(
      _queryController.text.trim(),
      category: _selectedCategory,
    );
    
    // Clear the input
    _queryController.clear();
    
    // Reset selected category
    setState(() {
      _selectedCategory = null;
      _isTyping = false;
    });
    
    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final legalService = Provider.of<LegalService>(context);
    final currentQuery = legalService.currentQuery;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Vakeel'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: currentQuery == null && !legalService.isLoading
                ? _buildEmptyState()
                : _buildResponseWidget(legalService, currentQuery),
          ),
          if (_isTyping) _buildCategorySelector(),
          _buildQueryInputBar(),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ask Your Legal Question',
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
              'Type your legal question below to get expert guidance from Vakeel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              _queryFocusNode.requestFocus();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Ask a question'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResponseWidget(LegalService legalService, LegalQuery? currentQuery) {
    if (legalService.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
            const SizedBox(height: 24),
            const Text(
              'Analyzing your legal question...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Question:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuery!.query,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (currentQuery.category != null)
            Chip(
              label: Text(
                LegalCategories.getCategoryDisplayName(currentQuery.category!),
              ),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legal Response:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: currentQuery.response ?? 'No response yet',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16),
                      h1: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor),
                      h2: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                      h3: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                      blockquote: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  currentQuery.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: currentQuery.isSaved
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  legalService.toggleSaveQuery(
                    currentQuery.id,
                    !currentQuery.isSaved,
                  );
                },
                tooltip: currentQuery.isSaved ? 'Remove from saved' : 'Save query',
              ),
            ],
          ),
          const SizedBox(height: 60), // Extra space for scrolling
        ],
      ),
    );
  }
  
  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: LegalCategories.getAllCategories().map((category) {
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(LegalCategories.getCategoryDisplayName(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildQueryInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              focusNode: _queryFocusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your legal question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.category_outlined),
                  onPressed: () {
                    setState(() {
                      _isTyping = !_isTyping;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty && _isTyping) {
                  setState(() {
                    _isTyping = false;
                  });
                } else if (value.isNotEmpty && !_isTyping) {
                  setState(() {
                    _isTyping = true;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _submitQuery,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}