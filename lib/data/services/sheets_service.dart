
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/blog_model.dart';
import '../models/course_model.dart';
import 'connectivity_service.dart';

class SheetsService {
  static Future<List<BlogModel>> fetchBlogs() async {
    try {
      // Check connectivity first
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
      // Check connectivity first
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
}
