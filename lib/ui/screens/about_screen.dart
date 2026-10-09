import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About Nexus Tech')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nexus Tech Learning',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version 1.2.0',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learn practical skills through focused courses, thoughtful articles and premium learning content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _section(context, 'What you can do', [
            _feature(
              context,
              Icons.school_outlined,
              'Learn by course',
              'Follow structured video lessons at your own pace.',
            ),
            _feature(
              context,
              Icons.article_outlined,
              'Read useful ideas',
              'Explore articles that connect concepts to real work.',
            ),
            _feature(
              context,
              Icons.track_changes_rounded,
              'Keep progressing',
              'Use the app as a simple home for your learning journey.',
            ),
            _feature(
              context,
              Icons.workspace_premium_outlined,
              'Unlock more',
              'Activate Premium to access lessons beyond the free plan.',
            ),
          ]),
          const SizedBox(height: 18),
          _section(context, 'Support & legal', [
            _action(
              context,
              Icons.mail_outline_rounded,
              'Contact support',
              'support@nexustech.com',
              () => _open('mailto:support@nexustech.com'),
            ),
            _action(
              context,
              Icons.language_rounded,
              'Visit website',
              'nexustech.com',
              () => _open('https://www.nexustech.com'),
            ),
            _action(
              context,
              Icons.privacy_tip_outlined,
              'Privacy and terms',
              'Read the in-app product notices',
              () => _notice(context),
            ),
          ]),
          const SizedBox(height: 22),
          Center(
            child: Text(
              '© 2024 Nexus Tech · Made for learners',
              style: TextStyle(color: colors.outline, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _feature(
    BuildContext context,
    IconData icon,
    String title,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _notice(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Product notices'),
      content: const Text(
        'Privacy Policy, Terms of Service and License Agreement summaries are available in this app. They are product notices and not a substitute for legal review.',
      ),
      actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
    ),
  );
}
