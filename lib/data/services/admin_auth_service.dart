import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  static const String _adminEmail = 'ak1500@gmail.com';
  
  static bool get isAdmin {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email == _adminEmail;
  }
  
  static String? get adminEmail {
    return isAdmin ? _adminEmail : null;
  }
  
  static Future<bool> checkAdminAccess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }
      
      // Force refresh to get latest user data
      await user.reload();
      await user.getIdToken(true);
      
      return user.email == _adminEmail;
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }
  
  static String get unauthorizedMessage {
    return 'Access denied. Admin privileges required for this operation.';
  }
}
