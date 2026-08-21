import 'package:flutter_test/flutter_test.dart';

import 'package:learning_app/data/models/blog_model.dart';
import 'package:learning_app/data/models/course_model.dart';
import 'package:learning_app/utils/validation_helper.dart';

void main() {
  group('content models', () {
    test('parses spreadsheet numeric values safely', () {
      final blog = BlogModel.fromJson({
        'id': 42,
        'title': ' Flutter Tips ',
        'content': 'Build better apps',
        'category': 'Mobile',
        'view_count': '12',
        'like_count': 3.9,
        'image_url': '',
      });

      expect(blog.id, '42');
      expect(blog.title, 'Flutter Tips');
      expect(blog.viewCount, 12);
      expect(blog.likeCount, 3);
      expect(blog.imageUrl, isNull);
    });

    test('extracts YouTube ids and formats durations', () {
      const video = VideoInfo(
        youtubeUrl: 'https://youtu.be/abc123?si=test',
        duration: '125',
      );

      expect(video.youtubeId, 'abc123');
      expect(video.displayThumbnailUrl, contains('abc123'));
      expect(video.durationFormatted, '02:05');
    });
  });

  group('validation', () {
    test('rejects empty required fields and invalid email', () {
      expect(ValidationHelper.validateRequired('  ', 'Title'), isNotNull);
      expect(ValidationHelper.validateEmail('not-an-email'), isNotNull);
      expect(ValidationHelper.validateEmail('learner@example.com'), isNull);
    });
  });
}
