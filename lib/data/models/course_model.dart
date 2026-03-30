class CourseModel {
  final String? id;
  final String? title;
  final List<String>? videos; // YouTube IDs

  CourseModel({
    this.id,
    this.title,
    this.videos,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      videos: (json['videos'] as List<dynamic>?)?.map((v) => v.toString()).toList(),
    );
  }
}
