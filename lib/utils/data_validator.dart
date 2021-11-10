class DataValidator {
  DataValidator._();

  static String? required<T>(T? value, {String? errorText}) {
    return (value == null) ? (errorText ?? 'This field is required') : null;
  }

  static String? textRequired(String? text, {String? errorText}) {
    final errMsg = errorText ?? 'Text is required';
    if (text == null) return errMsg;
    if (text.trim().isEmpty) return errMsg;
  }

  static String? lengthRequired(
    String? text, {
    String? fieldName,
    required int minLength,
    required int maxLength,
  }) {
    assert(minLength > 0, 'Min length must be a postive number');
    assert(maxLength > 0, 'Max length must be a postive number');
    if (text == null || text.trim().isEmpty) {
      return '${fieldName ?? 'Text'} is required';
    }
    if (text.length < minLength || text.length > maxLength) {
      return '${fieldName ?? 'Text'} must contain between $minLength and $maxLength characters';
    }
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
