class Validator {
  // ✅ Full Name Validator
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    final name = value.trim();

    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }

    // Allow letters + space only
    final regex = RegExp(r'^[a-zA-Z ]+$');

    if (!regex.hasMatch(name)) {
      return 'Only letters and spaces allowed';
    }

    return null;
  }

  // ✅ Username Validator
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final username = value.trim();

    if (username.contains(' ')) {
      return 'Username must not contain spaces';
    }

    if (username.length < 3) {
      return 'Minimum 3 characters required';
    }

    // lowercase + underscore only
    final regex = RegExp(r'^[a-z0-9_]+$');

    if (!regex.hasMatch(username)) {
      return 'Only lowercase letters, numbers, and underscore allowed';
    }

    if (username.startsWith('_') || username.endsWith('_')) {
      return 'Cannot start or end with underscore';
    }

    return null;
  }

  // ✅ Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }
}
