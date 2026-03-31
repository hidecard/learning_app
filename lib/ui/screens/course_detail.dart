import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../data/models/course_model.dart';
import '../../logic/controllers/premium_controller.dart';
import 'premium_screen.dart';

class CourseDetail extends StatelessWidget {
  const CourseDetail({super.key});

  dynamic get course => Get.arguments;

  @override
  Widget build(BuildContext context) {
    final List<VideoInfo> videos = course.videos ?? [];
    final authController = Get.find<AuthController>();
    final premiumController = Get.find<PremiumController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          course.title ?? 'Course',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C4852),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final isLocked = index >= 10 && !(authController.currentUser.value?.isPremium ?? false);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C2FF), Color(0xFF007BFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLocked
                    ? const Icon(Icons.lock, color: Colors.white, size: 24)
                    : const Icon(Icons.play_arrow, color: Colors.white, size: 24),
              ),
              title: Text(
                video.title ?? 'Video ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4852),
                  fontSize: 16,
                ),
              ),
              subtitle: video.category != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C2FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        video.category!,
                        style: const TextStyle(
                          color: Color(0xFF00C2FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
              trailing: isLocked
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C2FF), Color(0xFF007BFF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showPremiumDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Upgrade'),
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios, 
                    color: Color(0xFF00C2FF), 
                    size: 16),
              onTap: isLocked ? null : () => _playVideo(video.youtubeId, video.title),
            ),
          );
        },
      ),
    );
  }

  void _playVideo(String? youtubeId, String? title) {
    if (youtubeId == null || youtubeId.isEmpty) {
      Get.snackbar('Error', 'Invalid video URL');
      return;
    }

    Get.to(() => YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title ?? 'Video'),
            backgroundColor: const Color(0xFF00C2FF),
            foregroundColor: Colors.white,
          ),
          body: Center(child: player),
        );
      },
    ));
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: const Text('This video is only available for premium users. Upgrade to unlock all videos!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const PremiumScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
