import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../data/models/course_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoInfo video;
  final String? courseTitle;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.courseTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    
    final youtubeId = widget.video.youtubeId;
    print('YouTube ID: $youtubeId');
    print('YouTube URL: ${widget.video.youtubeUrl}');
    print('Video title: ${widget.video.title}');
    
    if (youtubeId == null || youtubeId.isEmpty) {
      print('Error: Invalid YouTube ID');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Invalid video URL');
        Navigator.pop(context);
      });
      return;
    }
    
    _controller = YoutubePlayerController(
      initialVideoId: youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        showLiveFullscreenButton: true,
        forceHD: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
    
    // Check for player errors - PlayerState doesn't have an error state, so we'll check other conditions
    if (_controller.value.hasError) {
      print('YouTube player error occurred');
      if (mounted) {
        Get.snackbar('Error', 'Failed to load video. Please try again.');
      }
    }
    
    // Log player state for debugging
    print('Player state: ${_controller.value.playerState}');
    print('Has error: ${_controller.value.hasError}');
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF00C2FF),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF00C2FF),
          handleColor: Color(0xFF007BFF),
        ),
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (metadata) {
          _showVideoCompletedDialog();
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final isDesktop = constraints.maxWidth > 1200;
            
            return Column(
              children: [
                // Custom App Bar with Glass Effect
                Container(
                  height: MediaQuery.of(context).padding.top + (isTablet ? 80 : 60),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.video.title ?? 'Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.courseTitle != null)
                                  Text(
                                    widget.courseTitle!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: isTablet ? 14 : 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share, color: Colors.white),
                              onPressed: _shareVideo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Video Player
                Expanded(
                  flex: isDesktop ? 3 : 2,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 1200 : double.infinity,
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Video Info Panel
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Video Title and Category
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.title ?? 'Video Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            if (widget.video.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00C2FF), Color(0xFF007BFF)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.video.category!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 24 : 20),
                      
                      // Action Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.thumb_up_outlined,
                                label: 'Like',
                                onTap: _likeVideo,
                                isTablet: isTablet,
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.bookmark_border,
                                label: 'Save',
                                onTap: _saveVideo,
                                isTablet: isTablet,
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.download_outlined,
                                label: 'Download',
                                onTap: _downloadVideo,
                                isTablet: isTablet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 24 : 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isTablet = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: Colors.white, 
              size: isTablet ? 24 : 20
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareVideo() {
    // Implement share functionality
    Get.snackbar('Share', 'Share functionality coming soon!');
  }

  void _likeVideo() {
    // Implement like functionality
    Get.snackbar('Liked', 'You liked this video!');
  }

  void _saveVideo() {
    // Implement save functionality
    Get.snackbar('Saved', 'Video saved to your library!');
  }

  void _downloadVideo() {
    // Implement download functionality
    Get.snackbar('Download', 'Download functionality coming soon!');
  }

  void _showVideoCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Video Completed',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You\'ve finished watching this video. Would you like to continue to the next video?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Replay', style: TextStyle(color: Color(0xFF00C2FF))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Next Video'),
          ),
        ],
      ),
    );
  }
}
