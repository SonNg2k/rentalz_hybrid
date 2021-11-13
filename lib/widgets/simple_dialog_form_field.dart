import 'package:flutter/material.dart';

/// Author: Son Xuan Nguyen
/// My SimpleDialogFormField widget in this file is inspired from the
/// TextFormField and DropdownButtonFormField widgets implemented by the
/// Flutter team:
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/text_form_field.dart#L85
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/dropdown.dart#L1503

class SimpleDialogFormField<T> extends FormField<T> {
  SimpleDialogFormField({
    ValueChanged<T>? onChanged,
    required List<T> values,
    // Only properties with [this] belong to this class
    required this.valueAsString,

    // From [super]
    Key? key,
    T? initialValue,
    FormFieldValidator<T>? validator,
    FormFieldSetter<T>? onSaved,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool enabled = true,

    // From [SimpleDialog]
    required Widget title,

    // From [TextField]
    // Key? key,
    // bool enabled = true,
    FocusNode? focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextStyle? style,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          onSaved: onSaved,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          builder: (FormFieldState<T> field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  /// if the user taps on the mask behind the dialog, then the
                  /// future below completes with the null value.
                  final selectedValue = await showDialog<T>(
                    context: field.context,
                    builder: (_) => SimpleDialog(
                      title: title,
                      children: [
                        for (final value in values)
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(field.context, value),
                            child: Text(valueAsString(value)),
                          ),
                      ],
                    ),
                  );
                  if (selectedValue != null && selectedValue != field.value) {
                    field.didChange(selectedValue);
                    if (onChanged != null) onChanged(selectedValue);
                  }
                },
                child: AbsorbPointer(
                  child: Theme(
                    data: field.hasError
                        ? ThemeData().copyWith(
                            colorScheme: ThemeData()
                                .colorScheme
                                .copyWith(primary: const Color(0xffd32f2f)),
                            inputDecorationTheme: const InputDecorationTheme(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffd32f2f),
                                ),
                              ),
                            ),
                          )
                        : Theme.of(field.context),
                    child: TextField(
                      readOnly: true,
                      showCursor: false,
                      style: style,
                      focusNode: focusNode,
                      decoration: decoration.copyWith(
                        floatingLabelBehavior: (field.value != null)
                            ? FloatingLabelBehavior.always
                            : null,
                        hintText: (field.value != null)
                            ? valueAsString(field.value!)
                            : null,
                        hintStyle: const TextStyle(color: Color(0xdd000000)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  field.errorText ?? '',
                  style: Theme.of(field.context)
                      .textTheme
                      .caption!
                      .copyWith(color: Theme.of(field.context).errorColor),
                ),
              ),
            ],
          ),
        );

  final String Function(T) valueAsString;

  @override
  FormFieldState<T> createState() => SimpleDialogFormFieldState<T>();
}

class SimpleDialogFormFieldState<T> extends FormFieldState<T> {
  @override
  SimpleDialogFormField<T> get widget =>
      super.widget as SimpleDialogFormField<T>;
}
