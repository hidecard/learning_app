import 'package:flutter_test/flutter_test.dart';

import 'package:learning_app/data/models/blog_model.dart';
import 'package:learning_app/data/models/course_model.dart';
import 'package:learning_app/data/models/user_model.dart';
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

  group('user profiles', () {
    test('supports legacy fields and clears activation keys', () {
      final user = UserModel.fromJson({
        'uid': 'user-1',
        'email': 'learner@example.com',
        'name': ' Learner ',
        'is_premium': 'true',
        'activation_key': 'ABC-123',
      });

      expect(user.id, 'user-1');
      expect(user.isPremium, isTrue);
      expect(user.activationKey, 'ABC-123');
      expect(user.copyWith(clearActivationKey: true).activationKey, isNull);
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
