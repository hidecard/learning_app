import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/course_model.dart';
import '../../logic/controllers/auth_controller.dart';
import 'video_player_screen.dart';

class CourseDetail extends StatelessWidget {
  const CourseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final course = Get.arguments as CourseModel;
    final videos = course.videos ?? const <VideoInfo>[];
    final isPremium =
        Get.find<AuthController>().currentUser.value?.isPremium == true;
    final colors = Theme.of(context).colorScheme;
    final freeCount = videos.length < 10 ? videos.length : 10;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title ?? 'Course'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/premium'),
            icon: const Icon(Icons.workspace_premium_outlined),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _header(
              context,
              course,
              videos.length,
              freeCount,
              isPremium,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Course lessons',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${videos.length} lessons · Start with the first lesson and learn at your pace.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                if (videos.isEmpty)
                  _empty(context)
                else
                  ...videos.asMap().entries.map(
                    (entry) => _lesson(
                      context,
                      entry.key,
                      entry.value,
                      isPremium,
                      course.title,
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    BuildContext context,
    CourseModel course,
    int lessonCount,
    int freeCount,
    bool isPremium,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6FED),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Icon(
                Icons.school_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: .9),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            course.title?.isNotEmpty == true
                ? course.title!
                : 'Untitled course',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn practical skills through focused video lessons.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(context, Icons.play_circle_outline, '$lessonCount lessons'),
              _pill(context, Icons.lock_open_outlined, '$freeCount free'),
              _pill(
                context,
                isPremium ? Icons.verified_outlined : Icons.lock_outline,
                isPremium ? 'Premium active' : 'Free plan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _lesson(
    BuildContext context,
    int index,
    VideoInfo video,
    bool isPremium,
    String? courseTitle,
  ) {
    final locked = index >= 10 && !isPremium;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => locked
              ? Get.toNamed('/premium')
              : Get.to(
                  () =>
                      VideoPlayerScreen(video: video, courseTitle: courseTitle),
                ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: locked
                        ? colors.surfaceContainerHighest
                        : colors.primaryContainer,
                  ),
                  child: Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.play_arrow_rounded,
                    color: locked ? colors.onSurfaceVariant : colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LESSON ${index + 1}',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.title?.isNotEmpty == true
                            ? video.title!
                            : 'Untitled lesson',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (video.category?.isNotEmpty == true)
                            Text(
                              video.category!,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          if (video.durationFormatted != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '· ${video.durationFormatted}',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  locked
                      ? Icons.chevron_right_rounded
                      : Icons.play_circle_outline_rounded,
                  color: locked ? colors.onSurfaceVariant : colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 10),
            const Text('Lessons will appear here soon.'),
          ],
        ),
      ),
    ),
  );
}
