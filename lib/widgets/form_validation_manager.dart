import 'package:flutter/material.dart';

/// This allows you to focus the first invalid [FormField] in a [Form] when
/// the submit button is tapped.
class FormValidationManager {
  final _fieldValidationStates = <String, FormFieldValidationState>{};

  void _ensureExists(String key) {
    _fieldValidationStates[key] ??= FormFieldValidationState(key: key);
  }

  List<FormFieldValidationState> get erroredFields =>
      _fieldValidationStates.entries
          .where((entry) => entry.value.hasError)
          .map((entry) => entry.value)
          .toList();

  FocusNode getFocusNodeForField(String key) {
    _ensureExists(key);
    return _fieldValidationStates[key]!.focusNode;
  }

  FormFieldValidator<T> wrapValidator<T>(
    String key,
    FormFieldValidator<T> validator,
  ) {
    _ensureExists(key);

    return (input) {
      final inputErrMsg = validator(input);
      _fieldValidationStates[key]!.hasError =
          (inputErrMsg?.isNotEmpty ?? false);
      return inputErrMsg;
    };
  }

  void dispose() {
    for (final entry in _fieldValidationStates.entries) {
      entry.value.focusNode.dispose();
    }
  }
}

class FormFieldValidationState {
  final String key;

  bool hasError;
  FocusNode focusNode;

  FormFieldValidationState({required this.key})
      : hasError = false,
        focusNode = FocusNode();
}
