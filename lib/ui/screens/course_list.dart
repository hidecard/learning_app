import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import 'course_detail.dart';

class CourseList extends StatelessWidget {
  final List<CourseModel> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No courses available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
            title: Text(
              course.title ?? 'Untitled Course',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: course.videos != null && course.videos!.isNotEmpty
                ? Text('${course.videos!.length} videos')
                : const Text('No videos'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Get.toNamed('/course-detail', arguments: course),
          ),
        );
      },
    );
  }
}
