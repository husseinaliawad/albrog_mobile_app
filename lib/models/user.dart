class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, username: $username, role: $role}';
  }
  
  /// الحصول على اسم الدور بالعربية
  String get roleDisplayName {
    switch (role?.toLowerCase()) {
      case 'administrator':
        return 'مشرف';
      case 'editor':
        return 'محرر';
      case 'author':
        return 'كاتب';
      case 'contributor':
        return 'مساهم';
      case 'subscriber':
        return 'مشترك';
      case 'customer':
        return 'عميل';
      case 'agent':
        return 'وسيط عقاري';
      default:
        return role ?? 'مستخدم';
    }
  }
} 