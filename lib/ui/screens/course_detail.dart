import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../data/models/course_model.dart';
import '../../logic/controllers/premium_controller.dart';
import 'premium_screen.dart';
import 'video_player_screen.dart';

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
      body: Column(
        children: [
          // Course Header with Stats
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C2FF), Color(0xFF007BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  return Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title ?? 'Course',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        if (isTablet)
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(icon: Icons.video_library, label: '${videos.length} Videos')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(icon: Icons.lock_open, label: '${videos.where((v) => videos.indexOf(v) < 10).length} Free')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(
                                icon: Icons.star,
                                label: authController.currentUser.value?.isPremium == true ? 'Premium' : 'Free',
                                isHighlighted: authController.currentUser.value?.isPremium == true,
                              )),
                            ],
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatCard(icon: Icons.video_library, label: '${videos.length} Videos'),
                              _buildStatCard(icon: Icons.lock_open, label: '${videos.where((v) => videos.indexOf(v) < 10).length} Free'),
                              _buildStatCard(
                                icon: Icons.star,
                                label: authController.currentUser.value?.isPremium == true ? 'Premium' : 'Free',
                                isHighlighted: authController.currentUser.value?.isPremium == true,
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Video List
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                
                return ListView.builder(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final isLocked = index >= 10 && !(authController.currentUser.value?.isPremium ?? false);
                    final videoNumber = index + 1;

                    return GestureDetector(
                      onTap: () {
                        print('Video tapped: ${video.title}');
                        print('YouTube ID: ${video.youtubeId}');
                        print('Is locked: $isLocked');
                        
                        if (isLocked) {
                          _showPremiumDialog(context);
                        } else {
                          _playVideo(video.youtubeId, video.title);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Video Thumbnail with Number
                            Container(
                              height: isTablet ? 140 : 120,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Thumbnail Image
                                  if (video.displayThumbnailUrl != null && !isLocked)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: Image.network(
                                        video.displayThumbnailUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF00C2FF).withOpacity(0.8),
                                                  const Color(0xFF007BFF).withOpacity(0.8),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF00C2FF).withOpacity(0.8),
                                                  const Color(0xFF007BFF).withOpacity(0.8),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded! /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF00C2FF).withOpacity(0.8),
                                            const Color(0xFF007BFF).withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  
                                  // Video Number
                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    child: Container(
                                      width: isTablet ? 48 : 40,
                                      height: isTablet ? 48 : 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$videoNumber',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: isTablet ? 18 : 16,
                                            color: const Color(0xFF007BFF),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Lock Icon or Play Icon
                                  Center(
                                    child: Container(
                                      width: isTablet ? 70 : 60,
                                      height: isTablet ? 70 : 60,
                                      decoration: BoxDecoration(
                                        color: isLocked 
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isLocked ? Icons.lock : Icons.play_arrow,
                                        size: isTablet ? 36 : 32,
                                        color: isLocked ? Colors.white : const Color(0xFF007BFF),
                                      ),
                                    ),
                                  ),
                                  
                                  // Duration Badge
                                  if (!isLocked && video.durationFormatted != null)
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          video.durationFormatted!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Video Info
                            Padding(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.title ?? 'Video $videoNumber',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C3E50),
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  SizedBox(height: isTablet ? 12 : 8),
                                  
                                  // Category and Lock Status
                                  Row(
                                    children: [
                                      if (video.category != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00C2FF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            video.category!,
                                            style: const TextStyle(
                                              color: Color(0xFF00C2FF),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      
                                      if (isLocked) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.lock, size: 12, color: Colors.orange),
                                              SizedBox(width: 4),
                                              Text(
                                                'Premium',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      
                                      const Spacer(),
                                      
                                      Icon(
                                        isLocked ? Icons.lock_outline : Icons.play_circle_outline,
                                        size: isTablet ? 22 : 20,
                                        color: isLocked ? Colors.orange : const Color(0xFF00C2FF),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(String? youtubeId, String? title) {
    if (youtubeId == null || youtubeId.isEmpty) {
      Get.snackbar('Error', 'Invalid video URL');
      return;
    }

    print('Playing video: $title');
    print('YouTube ID: $youtubeId');
    print('Course object: $course');
    print('Course title: ${course?.title}');

    // Create VideoInfo with proper YouTube URL and null safety
    final video = VideoInfo(
      title: title ?? 'Video',
      youtubeUrl: 'https://www.youtube.com/watch?v=$youtubeId',
    );

    print('Created video object with title: ${video.title}');

    // Safely get course title
    final courseTitle = course?.title?.toString() ?? 'Course';
    print('Final course title: $courseTitle');

    Get.to(() => VideoPlayerScreen(
      video: video,
      courseTitle: courseTitle,
    ));
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Text('Premium Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This video is only available for premium users.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upgrade to unlock all videos and enjoy ad-free learning!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFeatureItem(Icons.check_circle, 'Unlimited Access'),
                _buildFeatureItem(Icons.check_circle, 'HD Quality'),
                _buildFeatureItem(Icons.check_circle, 'Download Videos'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const PremiumScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
