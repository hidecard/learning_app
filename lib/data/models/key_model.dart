class KeyModel {
  final String keyCode;
  final bool isUsed;

  KeyModel({
    required this.keyCode,
    required this.isUsed,
  });

  factory KeyModel.fromJson(Map<String, dynamic> json) {
    return KeyModel(
      keyCode: json['key_code'] ?? '',
      isUsed: json['is_used'] ?? true,
    );
  }
}
