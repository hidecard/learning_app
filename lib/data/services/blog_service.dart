import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blog_model.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> incrementViewCount(String blogId) async {
    try {
      final blogRef = _firestore.collection('blogs').doc(blogId);
      
      // Use transaction to safely increment view count
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(blogRef);
        
        if (!docSnapshot.exists) {
          // Create the document if it doesn't exist
          transaction.set(blogRef, {
            'view_count': 1,
            'like_count': 0,
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          // Increment existing view count
          transaction.update(blogRef, {
            'view_count': FieldValue.increment(1),
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> toggleLike(String blogId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final blogRef = _firestore.collection('blogs').doc(blogId);
      final likeRef = _firestore.collection('blog_likes').doc('${blogId}_${user.uid}');

      // Use transaction to handle like toggle
      await _firestore.runTransaction((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final blogDoc = await transaction.get(blogRef);

        if (!blogDoc.exists) {
          // Create blog document if it doesn't exist
          transaction.set(blogRef, {
            'view_count': 0,
            'like_count': 1,
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          // Update like count
          final currentLikeCount = blogDoc.data()?['like_count'] as int? ?? 0;
          transaction.update(blogRef, {
            'like_count': likeDoc.exists ? FieldValue.increment(-1) : FieldValue.increment(1),
            'last_updated': FieldValue.serverTimestamp(),
          });
        }

        // Toggle user's like status
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
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<bool> isLikedByUser(String blogId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final likeDoc = await _firestore.collection('blog_likes').doc('${blogId}_${user.uid}').get();
      return likeDoc.exists;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  Future<int> getViewCount(String blogId) async {
    try {
      final docSnapshot = await _firestore.collection('blogs').doc(blogId).get();
      
      if (!docSnapshot.exists) {
        return 0;
      }
      
      final data = docSnapshot.data();
      return data?['view_count'] as int? ?? 0;
    } catch (e) {
      print('Error getting view count: $e');
      return 0;
    }
  }

  Future<int> getLikeCount(String blogId) async {
    try {
      final docSnapshot = await _firestore.collection('blogs').doc(blogId).get();
      
      if (!docSnapshot.exists) {
        return 0;
      }
      
      final data = docSnapshot.data();
      return data?['like_count'] as int? ?? 0;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }

  Future<BlogModel> updateBlogViewCount(BlogModel blog) async {
    try {
      await incrementViewCount(blog.id);
      final newViewCount = await getViewCount(blog.id);
      final newLikeCount = await getLikeCount(blog.id);
      return blog.copyWith(viewCount: newViewCount, likeCount: newLikeCount);
    } catch (e) {
      print('Error updating blog view count: $e');
      return blog;
    }
  }

  Future<BlogModel> updateBlogLikeCount(BlogModel blog) async {
    try {
      final newViewCount = await getViewCount(blog.id);
      final newLikeCount = await getLikeCount(blog.id);
      return blog.copyWith(viewCount: newViewCount, likeCount: newLikeCount);
    } catch (e) {
      print('Error updating blog like count: $e');
      return blog;
    }
  }
}
