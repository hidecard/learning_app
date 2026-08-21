import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/blog_model.dart';

class BlogStats {
  final int viewCount;
  final int likeCount;

  const BlogStats({this.viewCount = 0, this.likeCount = 0});
}

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> incrementViewCount(String blogId) async {
    if (blogId.isEmpty) return;
    try {
      final blogRef = _firestore.collection('blogs').doc(blogId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(blogRef);
        if (!snapshot.exists) {
          transaction.set(blogRef, {
            'view_count': 1,
            'like_count': 0,
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(blogRef, {
            'view_count': FieldValue.increment(1),
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {
      // Analytics must never prevent a user from opening an article.
    }
  }

  Future<void> toggleLike(String blogId) async {
    final user = _auth.currentUser;
    if (user == null || blogId.isEmpty) return;

    try {
      final blogRef = _firestore.collection('blogs').doc(blogId);
      final likeRef = _firestore
          .collection('blog_likes')
          .doc('${blogId}_${user.uid}');

      await _firestore.runTransaction((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final blogDoc = await transaction.get(blogRef);
        final delta = likeDoc.exists ? -1 : 1;

        if (blogDoc.exists) {
          transaction.update(blogRef, {
            'like_count': FieldValue.increment(delta),
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(blogRef, {
            'view_count': 0,
            'like_count': delta,
            'last_updated': FieldValue.serverTimestamp(),
          });
        }

        if (likeDoc.exists) {
          transaction.delete(likeRef);
        } else {
          transaction.set(likeRef, {
            'blog_id': blogId,
            'user_id': user.uid,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {
      // The card retains its previous state when an analytics update fails.
    }
  }

  Future<bool> isLikedByUser(String blogId) async {
    final user = _auth.currentUser;
    if (user == null || blogId.isEmpty) return false;
    try {
      final likeDoc = await _firestore
          .collection('blog_likes')
          .doc('${blogId}_${user.uid}')
          .get();
      return likeDoc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<BlogStats> getStats(String blogId) async {
    if (blogId.isEmpty) return const BlogStats();
    try {
      final snapshot = await _firestore.collection('blogs').doc(blogId).get();
      if (!snapshot.exists) return const BlogStats();
      final data = snapshot.data() ?? const <String, dynamic>{};
      return BlogStats(
        viewCount: _asInt(data['view_count']),
        likeCount: _asInt(data['like_count']),
      );
    } catch (_) {
      return const BlogStats();
    }
  }

  Future<int> getViewCount(String blogId) async =>
      (await getStats(blogId)).viewCount;

  Future<int> getLikeCount(String blogId) async =>
      (await getStats(blogId)).likeCount;

  Future<BlogModel> updateBlogViewCount(BlogModel blog) async {
    await incrementViewCount(blog.id);
    final stats = await getStats(blog.id);
    return blog.copyWith(
      viewCount: stats.viewCount,
      likeCount: stats.likeCount,
    );
  }

  Future<BlogModel> updateBlogLikeCount(BlogModel blog) async {
    final stats = await getStats(blog.id);
    return blog.copyWith(
      viewCount: stats.viewCount,
      likeCount: stats.likeCount,
    );
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
