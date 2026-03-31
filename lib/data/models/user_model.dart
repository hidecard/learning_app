class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final String? activationKey;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    this.activationKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['email']?.split('@')[0] ?? 'User',
      isPremium: json['is_premium'] ?? false,
      activationKey: json['activation_key'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'is_premium': isPremium,
    'activation_key': activationKey,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    String? activationKey,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      activationKey: activationKey ?? this.activationKey,
    );
  }
}
