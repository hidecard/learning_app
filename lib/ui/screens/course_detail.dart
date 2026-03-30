import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../data/models/course_model.dart';
import '../../logic/controllers/premium_controller.dart';

class CourseDetail extends StatelessWidget {
  const CourseDetail({super.key});

  dynamic get course => Get.arguments;

  @override
  Widget build(BuildContext context) {
    final List<String> videos = List<String>.from(course.videos ?? []);
    final authController = Get.find<AuthController>();
    final premiumController = Get.put(PremiumController());

    return Scaffold(
      appBar: AppBar(title: Text(course.title ?? '')),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final ytId = videos[index];
          final isLocked = index >= 10 && !(authController.currentUser.value?.isPremium ?? false);

          return ListTile(
            title: Text('Video $index'),
            leading: isLocked ? const Icon(Icons.lock, color: Colors.red) : const Icon(Icons.play_circle),
            trailing: isLocked
                ? ElevatedButton(
                    onPressed: () => Get.toNamed('/premium'),
                    child: const Text('Upgrade'),
                  )
                : null,
            onTap: isLocked ? null : () => _playVideo(ytId),
          );
        },
      ),
    );
  }

  void _playVideo(String ytId) {
    Get.to(() => YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: ytId,
          flags: const YoutubePlayerFlags(autoPlay: true),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text('Video $ytId')),
          body: Center(child: player),
        );
      },
    ));
  }
}
