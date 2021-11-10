class DataValidator {
  DataValidator._();

  static String? required<T>(T? value, {String? errorText}) {
    return (value == null) ? (errorText ?? 'This field is required') : null;
  }

  static String? textRequired(String? value, {String? errorText}) {
    final errMsg = errorText ?? 'Text is required';
    if (value == null) return errMsg;
    if (value.trim().isEmpty) return errMsg;
  }

  static String? emailAddressValid(String? email) {
    if (email == null || email.trim().isEmpty) return 'Email is required';
    final trimmedEmail = email.trim();
    if (trimmedEmail.length < 5 || trimmedEmail.length > 50) {
      return 'Email must contain between 5 and 50 characters';
    }
    final emailRegex = RegExp(
      r'''^(([^<>()\[\]\\.,;:\s-@#$!%^&*+=_/`?{}|'"]+(\.[^<>()\[\]\\.,;:\s-@_!#$%^&*()=+/`?{}|'"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$''',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(email)) return 'Email is not valid';
  }
}
