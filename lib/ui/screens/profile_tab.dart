import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../logic/controllers/theme_controller.dart';
import '../../logic/controllers/learning_state_controller.dart';
import 'about_screen.dart';
import 'activation_key_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/glass_surface.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [IconButton(onPressed: auth.signOut, icon: const Icon(Icons.logout_rounded))]),
      body: Obx(() {
        final user = auth.currentUser.value;
        if (user == null) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          _profileCard(context, user),
          const SizedBox(height: 24),
          _label(context, 'ACCOUNT'),
          _group(context, [
            _row(context, Icons.person_outline_rounded, 'Edit profile', 'Update your name and details', () => Get.to(() => const EditProfileScreen())),
            _row(context, Icons.key_rounded, 'Activation key', user.isPremium ? 'Premium access is active' : 'Unlock all lessons', () => Get.to(() => const ActivationKeyScreen()), badge: user.isPremium ? 'Active' : null),
          ]),
          const SizedBox(height: 20),
          _label(context, 'PREFERENCES'),
          _group(context, [
            _themeRow(context),
            _row(context, Icons.info_outline_rounded, 'About CodeNest', 'Privacy, terms and app information', () => Get.to(() => const AboutScreen())),
          ]),
          const SizedBox(height: 20),
          _label(context, 'YOUR LIBRARY'),
          Obx(() {
            final learning = Get.find<LearningStateController>();
            return _group(context, [
              _row(context, Icons.bookmark_outline_rounded, 'Saved courses', '${learning.savedCourses.length} saved courses', () => Get.snackbar('Saved courses', 'Open a course from your saved library when it appears in the course list.')),
              _row(context, Icons.article_outlined, 'Saved articles', '${learning.savedBlogs.length} saved articles', () => Get.snackbar('Saved articles', 'Open an article from your saved library when it appears in the article list.')),
              _row(context, Icons.download_done_rounded, 'Offline lessons', '${learning.downloadedLessons.length} lessons saved on this device', () => Get.snackbar('Offline lessons', 'Open a saved lesson from its course page to continue learning.')),
            ]);
          }),
          const SizedBox(height: 20),
          _label(context, 'SESSION'),
          _group(context, [_row(context, Icons.logout_rounded, 'Sign out', 'You can sign back in anytime', () => _confirmLogout(context, auth), danger: true)]),
        ]);
      }),
    );
  }

  Widget _profileCard(BuildContext context, UserModel user) {
    final initials = user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase();
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF0B0F10), borderRadius: BorderRadius.circular(24)), child: Row(children: [
      CircleAvatar(radius: 31, backgroundColor: Colors.white.withValues(alpha: .18), child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24))),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)), const SizedBox(height: 4), Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(user.isPremium ? Icons.workspace_premium_rounded : Icons.school_outlined, size: 14, color: Colors.white), const SizedBox(width: 5), Text(user.isPremium ? 'Premium learner' : 'Free learner', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))]))]))
    ]));
  }

  Widget _label(BuildContext context, String text) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)));

  Widget _group(BuildContext context, List<Widget> children) => GlassSurface(
    borderRadius: BorderRadius.circular(22),
    child: Column(children: [for (var i = 0; i < children.length; i++) ...[children[i], if (i != children.length - 1) const Divider(height: 1, indent: 64)]]),
  );

  Widget _row(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, {String? badge, bool danger = false}) {
    final colors = Theme.of(context).colorScheme;
    final color = danger ? colors.error : colors.primary;
    return ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)), title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: danger ? color : null)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: badge != null ? Chip(label: Text(badge), visualDensity: VisualDensity.compact, backgroundColor: colors.secondaryContainer) : const Icon(Icons.chevron_right_rounded));
  }

  Widget _themeRow(BuildContext context) => Obx(() { final theme = Get.find<ThemeController>(); return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .11), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.dark_mode_outlined)), title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Adjust the app appearance', style: TextStyle(fontSize: 12)), trailing: Switch(value: theme.isDarkMode.value, onChanged: (_) => theme.toggleTheme())); });

  void _confirmLogout(BuildContext context, AuthController auth) => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Sign out?'), content: const Text('Your learning content will stay safe on this device.'), actions: [TextButton(onPressed: Get.back, child: const Text('Cancel')), FilledButton(onPressed: () { Get.back(); auth.signOut(); }, child: const Text('Sign out'))]));
}
