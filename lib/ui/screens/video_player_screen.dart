import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import '../../data/services/learning_progress_service.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../logic/controllers/learning_state_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoInfo video;
  final String? courseTitle;
  final List<VideoInfo> playlist;
  final int videoIndex;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.courseTitle,
    this.playlist = const <VideoInfo>[],
    this.videoIndex = 0,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _hasReportedError = false;
  final _progress = LearningProgressService();

  @override
  void initState() {
    super.initState();

    final youtubeId = widget.video.youtubeId;
    if (youtubeId == null || youtubeId.isEmpty) {
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
    _progress.markStarted(widget.courseTitle, widget.video);
  }

  void _listener() {
    final controller = _controller;
    if (controller == null ||
        !mounted ||
        !controller.value.hasError ||
        _hasReportedError) {
      return;
    }
    _hasReportedError = true;
    Get.snackbar(
      'Video unavailable',
      'Failed to load this video. Please try again.',
    );
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video unavailable')),
        body: const Center(child: Text('This video link is not valid.')),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFFFFFFF),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFFFFFFF),
          handleColor: Color(0xFF273031),
        ),
        onEnded: (metadata) {
          _completeAndContinue();
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
                // Plain app bar with clear video context
                Container(
                  height:
                      MediaQuery.of(context).padding.top + (isTablet ? 80 : 60),
                  color: Colors.black,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: _closePlayer,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
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
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
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
                        child: AspectRatio(aspectRatio: 16 / 9, child: player),
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
                        color: Colors.black.withValues(alpha: 0.3),
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
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Video Title and Category
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                        ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF273031),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                        ),
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
                              child: Obx(() {
                                final saved = Get.find<LearningStateController>()
                                    .isVideoSaved(widget.courseTitle, widget.video);
                                return _buildActionButton(
                                  icon: saved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border,
                                  label: saved ? 'Saved' : 'Save',
                                  onTap: _saveVideo,
                                  isTablet: isTablet,
                                );
                              }),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: Obx(() {
                                final saved = Get.find<LearningStateController>()
                                    .isVideoDownloaded(widget.courseTitle, widget.video);
                                return _buildActionButton(
                                  icon: saved ? Icons.download_done_rounded : Icons.download_outlined,
                                  label: saved ? 'Saved offline' : 'Download',
                                  onTap: _downloadVideo,
                                  isTablet: isTablet,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                        ),
                        child: Obx(() {
                          final note = Get.find<LearningStateController>()
                              .noteForVideo(widget.courseTitle, widget.video);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _editNote,
                              icon: Icon(
                                note.isEmpty
                                    ? Icons.edit_note_rounded
                                    : Icons.sticky_note_2_rounded,
                              ),
                              label: Text(note.isEmpty ? 'Add lesson note' : 'Edit lesson note'),
                            ),
                          );
                        }),
                      ),

                      if (widget.playlist.length > 1) ...[
                        SizedBox(height: isTablet ? 16 : 12),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: widget.videoIndex > 0
                                      ? () => _openLesson(widget.videoIndex - 1)
                                      : null,
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  label: const Text('Previous'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed:
                                      widget.videoIndex + 1 <
                                          widget.playlist.length
                                      ? () => _openLesson(widget.videoIndex + 1)
                                      : null,
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  label: const Text('Next lesson'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
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
    final learning = Get.find<LearningStateController>();
    final saved = learning.isVideoSaved(widget.courseTitle, widget.video);
    learning.toggleVideoSaved(widget.courseTitle, widget.video);
    Get.snackbar(
      saved ? 'Removed' : 'Saved',
      saved ? 'Lesson removed from saved items.' : 'Lesson saved to your library.',
    );
  }

  Future<void> _editNote() async {
    final learning = Get.find<LearningStateController>();
    final controller = TextEditingController(
      text: learning.noteForVideo(widget.courseTitle, widget.video),
    );
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lesson note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Write a short note about this lesson',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save note'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    await learning.saveVideoNote(widget.courseTitle, widget.video, note);
    Get.snackbar(
      'Note saved',
      note.trim().isEmpty ? 'Lesson note removed.' : 'Your note is saved on this device.',
    );
  }

  void _downloadVideo() {
    final isPremium = Get.find<AuthController>().currentUser.value?.isPremium == true;
    if (!isPremium) {
      Get.snackbar('Premium feature', 'Activate Premium to save lessons for offline access.');
      Get.toNamed('/premium');
      return;
    }
    final learning = Get.find<LearningStateController>();
    final saved = learning.isVideoDownloaded(widget.courseTitle, widget.video);
    learning.toggleVideoDownload(widget.courseTitle, widget.video);
    Get.snackbar(
      saved ? 'Removed from offline library' : 'Saved for offline access',
      saved ? 'This lesson was removed from this device.' : 'You can find it in your Profile library.',
    );
  }

  void _closePlayer() {
    _controller?.pause();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeAndContinue() async {
    await _progress.markCompleted(widget.courseTitle, widget.video);
    if (mounted) _showVideoCompletedDialog();
  }

  void _openLesson(int index) {
    if (index < 0 || index >= widget.playlist.length) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          video: widget.playlist[index],
          courseTitle: widget.courseTitle,
          playlist: widget.playlist,
          videoIndex: index,
        ),
      ),
    );
  }

  void _showVideoCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Replay',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
          ElevatedButton(
            onPressed: widget.videoIndex + 1 < widget.playlist.length
                ? () {
                    Navigator.of(dialogContext).pop();
                    _openLesson(widget.videoIndex + 1);
                  }
                : () {
                    Navigator.of(dialogContext).pop();
                    _closePlayer();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFFFF),
              foregroundColor: Colors.white,
            ),
            child: Text(
              widget.videoIndex + 1 < widget.playlist.length
                  ? 'Next Video'
                  : 'Done',
            ),
          ),
        ],
      ),
    );
  }
}
