class LegalQuery {
  final int id;
  final int userId;
  final String query;
  final String? response;
  final String? category;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  LegalQuery({
    required this.id,
    required this.userId,
    required this.query,
    this.response,
    this.category,
    required this.isSaved,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory LegalQuery.fromJson(Map<String, dynamic> json) {
    return LegalQuery(
      id: json['id'],
      userId: json['user_id'],
      query: json['query'],
      response: json['response'],
      category: json['category'],
      isSaved: json['is_saved'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'query': query,
      'response': response,
      'category': category,
      'is_saved': isSaved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  LegalQuery copyWith({
    int? id,
    int? userId,
    String? query,
    String? response,
    String? category,
    bool? isSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegalQuery(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      query: query ?? this.query,
      response: response ?? this.response,
      category: category ?? this.category,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Helper class for legal query categories
class LegalCategories {
  static const String criminal = 'criminal';
  static const String civil = 'civil';
  static const String family = 'family';
  static const String property = 'property';
  static const String employment = 'employment';
  static const String constitutional = 'constitutional';
  static const String immigration = 'immigration';
  static const String general = 'general';
  
  static List<String> getAllCategories() {
    return [
      criminal,
      civil,
      family,
      property,
      employment,
      constitutional,
      immigration,
      general,
    ];
  }
  
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case criminal:
        return 'Criminal Law';
      case civil:
        return 'Civil Law';
      case family:
        return 'Family Law';
      case property:
        return 'Property Law';
      case employment:
        return 'Employment Law';
      case constitutional:
        return 'Constitutional Law';
      case immigration:
        return 'Immigration Law';
      case general:
        return 'General Legal Inquiry';
      default:
        return 'Unknown';
    }
  }
  
  static String getCategoryIcon(String category) {
    // These would be font icons or asset paths
    switch (category) {
      case criminal:
        return 'justice';
      case civil:
        return 'balance';
      case family:
        return 'family';
      case property:
        return 'home';
      case employment:
        return 'work';
      case constitutional:
        return 'document';
      case immigration:
        return 'passport';
      case general:
        return 'question';
      default:
        return 'question';
    }
  }
}