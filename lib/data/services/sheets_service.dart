
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/blog_model.dart';
import '../models/course_model.dart';
import 'connectivity_service.dart';

class SheetsService {
  static const String _adminEmail = 'ak1500@gmail.com';

  static Future<List<BlogModel>> fetchBlogs() async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        if (kDebugMode) {
          print('No internet connection - cannot fetch blogs');
        }
        return [];
      }
      
      if (kDebugMode) {
        print('Fetching blogs from: $BLOGS_ENDPOINT');
      }
      
      final response = await http.get(Uri.parse(BLOGS_ENDPOINT));
      
      if (kDebugMode) {
        print('Blogs response status: ${response.statusCode}');
        print('Blogs response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print('Parsed ${data.length} blogs');
        }
        return data.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load blogs: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching blogs: $e');
      }
      return [];
    }
  }

  static Future<List<CourseModel>> fetchCourses() async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        if (kDebugMode) {
          print('No internet connection - cannot fetch courses');
        }
        return [];
      }
      
      if (kDebugMode) {
        print('Fetching courses from: $COURSES_ENDPOINT');
      }
      
      final response = await http.get(Uri.parse(COURSES_ENDPOINT));
      
      if (kDebugMode) {
        print('Courses response status: ${response.statusCode}');
        print('Courses response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print('Parsed ${data.length} courses');
        }
        return data.map((json) => CourseModel.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load courses: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching courses: $e');
      }
      return [];
    }
  }

  // CRUD Operations for Blogs
  static Future<Map<String, dynamic>> createBlog(BlogModel blog) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'create',
        'type': 'blogs',
        'admin': _adminEmail,
        'id': blog.id,
        'title': blog.title,
        'content': blog.content,
        'category': blog.category,
        'image_url': blog.imageUrl ?? '',
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to create blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateBlog(BlogModel blog) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'update',
        'type': 'blogs',
        'admin': _adminEmail,
        'id': blog.id,
        'title': blog.title,
        'content': blog.content,
        'category': blog.category,
        'image_url': blog.imageUrl,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to update blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteBlog(String blogId) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'delete',
        'type': 'blogs',
        'admin': _adminEmail,
        'id': blogId,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to delete blog'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting blog: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // CRUD Operations for Courses
  static Future<Map<String, dynamic>> createCourseVideo({
    required String courseName,
    required String videoTitle,
    required String youtubeUrl,
    required String category,
  }) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'create',
        'type': 'courses',
        'admin': _adminEmail,
        'course_name': courseName,
        'video_title': videoTitle,
        'youtube_url': youtubeUrl,
        'category': category,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to create course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCourseVideo({
    required int row,
    String? courseName,
    String? videoTitle,
    String? youtubeUrl,
    String? category,
  }) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final queryParams = <String, String>{
        'operation': 'update',
        'type': 'courses',
        'admin': _adminEmail,
        'row': row.toString(),
      };

      if (courseName != null) queryParams['course_name'] = courseName;
      if (videoTitle != null) queryParams['video_title'] = videoTitle;
      if (youtubeUrl != null) queryParams['youtube_url'] = youtubeUrl;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: queryParams);

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to update course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteCourseVideo(int row) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'delete',
        'type': 'courses',
        'admin': _adminEmail,
        'row': row.toString(),
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'error': 'Failed to delete course video'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting course video: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get raw courses data for admin (with row numbers)
  static Future<List<Map<String, dynamic>>> fetchCoursesRaw() async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      if (!connectivityService.isConnected.value) {
        return [];
      }

      final uri = Uri.parse(SHEETS_API_BASE).replace(queryParameters: {
        'operation': 'read',
        'type': 'courses_raw',
        'admin': _adminEmail,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching raw courses: $e');
      }
      return [];
    }
  }
}
