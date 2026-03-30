import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'logic/controllers/auth_controller.dart';
import 'logic/controllers/premium_controller.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/premium_screen.dart';
import 'ui/screens/course_detail.dart';
import 'ui/screens/blog_detail.dart';
import 'data/models/blog_model.dart';
import 'data/models/course_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(PremiumController());
      }),
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/auth', page: () => const AuthScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/premium', page: () => const PremiumScreen()),
        GetPage(name: '/course-detail', page: () => const CourseDetail()),
        GetPage(name: '/blog-detail', page: () {
          final blog = Get.arguments as BlogModel;
          return BlogDetail(blog: blog);
        }),
      ],
    );
  }
}
