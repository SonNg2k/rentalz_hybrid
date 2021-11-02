String? checkIfEmailIsValid(String? email) {
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
