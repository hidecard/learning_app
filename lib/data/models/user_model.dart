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
    final email = json['email']?.toString().trim() ?? '';
    final rawName = json['name']?.toString().trim() ?? '';
    final rawPremium = json['is_premium'];
    final isPremium = rawPremium is bool
        ? rawPremium
        : rawPremium?.toString().toLowerCase() == 'true';
    final rawActivationKey = json['activation_key']?.toString().trim();

    return UserModel(
      id: (json['id'] ?? json['uid'])?.toString() ?? '',
      email: email,
      name: rawName.isNotEmpty
          ? rawName
          : (email.isEmpty ? 'User' : email.split('@').first),
      isPremium: isPremium,
      activationKey: rawActivationKey?.isEmpty == true
          ? null
          : rawActivationKey,
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
