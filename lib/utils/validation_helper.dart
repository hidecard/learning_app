class ValidationHelper {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a YouTube URL';
    }
    
    final urlPatterns = [
      RegExp(r'^(https?:\/\/)?(www\.)?youtube\.com\/watch\?v=[\w-]+', caseSensitive: false),
      RegExp(r'^(https?:\/\/)?(www\.)?youtu\.be\/[\w-]+', caseSensitive: false),
      RegExp(r'^(https?:\/\/)?(www\.)?youtube\.com\/embed\/[\w-]+', caseSensitive: false),
      RegExp(r'^(https?:\/\/)?(www\.)?youtube\.com\/v\/[\w-]+', caseSensitive: false),
    ];
    
    bool isValid = urlPatterns.any((pattern) => pattern.hasMatch(value));
    
    if (!isValid) {
      return 'Please enter a valid YouTube URL';
    }
    
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URLs are optional
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }

  static String? validateActivationKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an activation key';
    }
    
    final keyRegex = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$');
    if (!keyRegex.hasMatch(value.toUpperCase())) {
      return 'Activation key must be in format XXX-XXX (e.g., ABC-123)';
    }
    
    return null;
  }
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }
    
    if (error is String) {
      return error;
    }
    
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error.toString().contains('Unauthorized')) {
      return 'Access denied. You do not have permission to perform this action.';
    }
    
    if (error.toString().contains('NotFound')) {
      return 'The requested resource was not found.';
    }
    
    return error.toString();
  }

  static void showErrorSnackBar(String message) {
    // This would use Get.snackbar in the actual implementation
    // Keeping it separate for reusability
  }

  static void showSuccessSnackBar(String message) {
    // This would use Get.snackbar in the actual implementation
    // Keeping it separate for reusability
  }
}
