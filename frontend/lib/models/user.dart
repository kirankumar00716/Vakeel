class User {
  final int id;
  final String username;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Profile {
  final int id;
  final int userId;
  final String? fullName;
  final String? bio;
  final String? avatar;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Profile({
    required this.id,
    required this.userId,
    this.fullName,
    this.bio,
    this.avatar,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      bio: json['bio'],
      avatar: json['avatar'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
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
      'full_name': fullName,
      'bio': bio,
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  Profile copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? bio,
    String? avatar,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}