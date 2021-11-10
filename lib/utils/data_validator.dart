/// The all-in-one class to validate all kinds of data for this app. Decouple
/// all validation logics from your UI logic.
class DataValidator {
  DataValidator._();

  static String? required<T>(T? value, {String? labelText}) {
    return (value == null) ? '${labelText ?? 'This field'} is required' : null;
  }

  static String? textRequired(String? value, {String? labelText}) {
    final errMsg = '${labelText ?? 'This field'} is required';
    if (value == null) return errMsg;
    if (value.trim().isEmpty) return errMsg;
  }

  static String? fullnameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fullname is required';
    }
    if (value.trim().length < 4 || value.trim().length > 64) {
      return 'Name must contain between 4 and 64 characters';
    }

    /// Only accepts letters, comma, dot, single quote, and hyphen.
    final _fullnameRegex = RegExp(
      r"^[a-z àáâãèéêếìíòóôõùúăđĩũơưăạảấầẩẫậắằẳẵặẹẻẽềềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ,.'-]+$",
      unicode: true,
      caseSensitive: false,
    );
    if (!_fullnameRegex.hasMatch(value)) {
      return 'Please remove invalid characters from your name';
    }
  }

  static String? lengthRequired(
    String? value, {
    String? labelText,
    required int minLength,
    required int maxLength,
  }) {
    assert(minLength > 0, 'Min length must be a postive number');
    assert(maxLength > 0, 'Max length must be a postive number');
    if (value == null || value.trim().isEmpty) {
      return '${labelText ?? 'This field'} is required';
    }
    if (value.length < minLength || value.length > maxLength) {
      return '${labelText ?? 'This field'} must contain between $minLength and $maxLength characters';
    }
  }

  static String? emailAddressValid(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (value.trim().length < 5 || value.trim().length > 50) {
      return 'Email must contain between 5 and 50 characters';
    }
    final emailRegex = RegExp(
      r'''^(([^<>()\[\]\\.,;:\s-@#$!%^&*+=_/`?{}|'"]+(\.[^<>()\[\]\\.,;:\s-@_!#$%^&*()=+/`?{}|'"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$''',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(value)) return 'Email is not valid';
  }
}
