/// The all-in-one class to validate all kinds of data for this app. Decouple
/// all validation logics from your UI logic.
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

  static String? fullnameValid(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Fullname is required';
    }
    if (text.trim().length < 4 || text.trim().length > 64) {
      return 'Name must contain between 4 and 64 characters';
    }

    /// Only accepts letters, comma, dot, single quote, and hyphen.
    final _fullnameRegex = RegExp(
      r"^[a-z àáâãèéêếìíòóôõùúăđĩũơưăạảấầẩẫậắằẳẵặẹẻẽềềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ,.'-]+$",
      unicode: true,
      caseSensitive: false,
    );
    if (!_fullnameRegex.hasMatch(text)) {
      return 'Please remove invalid characters from your name';
    }
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
    if (email.trim().length < 5 || email.trim().length > 50) {
      return 'Email must contain between 5 and 50 characters';
    }
    final emailRegex = RegExp(
      r'''^(([^<>()\[\]\\.,;:\s-@#$!%^&*+=_/`?{}|'"]+(\.[^<>()\[\]\\.,;:\s-@_!#$%^&*()=+/`?{}|'"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$''',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(email)) return 'Email is not valid';
  }
}
