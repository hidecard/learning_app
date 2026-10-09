import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/services/connectivity_service.dart';
import 'firebase_options.dart';
import 'logic/controllers/auth_controller.dart';
import 'logic/controllers/premium_controller.dart';
import 'logic/controllers/theme_controller.dart';
import 'ui/screens/admin_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/blog_detail.dart';
import 'ui/screens/course_detail.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/screens/premium_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/widgets/connectivity_wrapper.dart';
import 'ui/widgets/glass_surface.dart';

const _brandBlue = Color(0xFF087EA4);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthController(), permanent: true);
  Get.put(PremiumController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _brandBlue,
          brightness: brightness,
          surface: brightness == Brightness.dark
              ? const Color(0xFF0F1720)
              : const Color(0xFFF7F9FC),
        ).copyWith(
          primary: brightness == Brightness.dark
              ? const Color(0xFF55C8E8)
              : const Color(0xFF087EA4),
          secondary: brightness == Brightness.dark
              ? const Color(0xFF86A8FF)
              : const Color(0xFF3867D6),
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.42)
            : Colors.white.withValues(alpha: .62),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: brightness == Brightness.dark
            ? colorScheme.surfaceContainer.withValues(alpha: .68)
            : Colors.white.withValues(alpha: .68),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: brightness == Brightness.dark ? .12 : .62),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: .7),
        space: 1,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: brightness == Brightness.dark
            ? colorScheme.surface.withValues(alpha: .82)
            : Colors.white.withValues(alpha: .86),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: brightness == Brightness.dark
            ? colorScheme.surface.withValues(alpha: .72)
            : Colors.white.withValues(alpha: .72),
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: brightness == Brightness.dark
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Tech Learning',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: themeController.themeMode,
      builder: (context, child) =>
          GlassBackdrop(
            child: ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
          ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/auth', page: () => const AuthScreen()),
        GetPage(name: '/main', page: () => const MainNavigation()),
        GetPage(name: '/premium', page: () => const PremiumScreen()),
        GetPage(name: '/course-detail', page: () => const CourseDetail()),
        GetPage(
          name: '/blog-detail',
          page: () => BlogDetail(blog: Get.arguments),
        ),
        GetPage(name: '/admin', page: () => const AdminScreen()),
      ],
    );
  }
}
