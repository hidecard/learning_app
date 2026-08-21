class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final String? activationKey;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    this.activationKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] as String? ?? '').trim();
    return UserModel(
      id: json['id'] as String? ?? '',
      email: email,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : (email.isEmpty ? 'User' : email.split('@').first),
      isPremium: json['is_premium'] as bool? ?? false,
      activationKey: json['activation_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'is_premium': isPremium,
    if (activationKey != null) 'activation_key': activationKey,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    String? activationKey,
    bool clearActivationKey = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      activationKey: clearActivationKey
          ? null
          : activationKey ?? this.activationKey,
    );
  }
}
