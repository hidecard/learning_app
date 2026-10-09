import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/course_model.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../logic/controllers/learning_state_controller.dart';
import 'video_player_screen.dart';

class CourseDetail extends StatelessWidget {
  const CourseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final course = Get.arguments as CourseModel;
    final videos = course.videos ?? const <VideoInfo>[];
    final isPremium =
        Get.find<AuthController>().currentUser.value?.isPremium == true;
    final learning = Get.find<LearningStateController>();
    final colors = Theme.of(context).colorScheme;
    final freeCount = videos.length < 10 ? videos.length : 10;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title ?? 'Course'),
        actions: [
          Obx(() => IconButton(
            tooltip: learning.isCourseSaved(course) ? 'Remove saved course' : 'Save course',
            onPressed: () => learning.toggleCourseSaved(course),
            icon: Icon(learning.isCourseSaved(course) ? Icons.bookmark : Icons.bookmark_border),
          )),
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
                Obx(() {
                  final progress = learning.progressFor(course);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: LinearProgressIndicator(value: progress, minHeight: 7)),
                        const SizedBox(width: 10),
                        Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 6),
                      Text('${learning.completedCount(course)} of ${videos.length} lessons completed', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
                    ],
                  );
                }),
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
                      course,
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
    CourseModel course,
  ) {
    final locked = index >= 10 && !isPremium;
    final colors = Theme.of(context).colorScheme;
    final completed = Get.find<LearningStateController>().isLessonCompleted(course, index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => locked
              ? Get.toNamed('/premium')
              : Get.to(
                  () => VideoPlayerScreen(
                    video: video,
                    courseTitle: courseTitle,
                    course: course,
                    lessonIndex: index,
                  ),
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
                    color: completed
                        ? colors.tertiaryContainer
                        : locked
                            ? colors.surfaceContainerHighest
                            : colors.primaryContainer,
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : locked
                            ? Icons.lock_outline_rounded
                            : Icons.play_arrow_rounded,
                    color: completed
                        ? colors.tertiary
                        : locked
                            ? colors.onSurfaceVariant
                            : colors.primary,
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
