class UserModel {
  final String id;
  final String email;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.email,
    required this.isPremium,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      isPremium: json['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_premium': isPremium,
  };
}
