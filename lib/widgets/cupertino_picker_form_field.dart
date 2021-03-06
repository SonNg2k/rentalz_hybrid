/// Author: Son Xuan Nguyen
/// My CupertinoPickerFormField widget in this file is inspired from the
/// TextFormField and DropdownButtonFormField widgets implemented by the
/// Flutter team:
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/text_form_field.dart#L85
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/dropdown.dart#L1503
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A convenience widget that makes a [CupertinoPicker] into a [FormField].
/// This should be used if you have more than five select options.
class CupertinoPickerFormField<T> extends FormField<T> {
  CupertinoPickerFormField({
    // Features
    // this.resetIcon = const Icon(Icons.close),
    ValueChanged<T?>? onPickerClose,
    required List<T> values,
    // Only properties with [this] belong to this class
    required this.valueAsString,

    // From [super]
    Key? key,
    FormFieldSetter<T>? onSaved,
    FormFieldValidator<T>? validator,
    T? initialValue,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool enabled = true,

    // From [TextField]
    // Key? key,
    // T? initialValue,
    // bool enabled = true,
    FocusNode? focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextStyle? style,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<T> field) {
            final CupertinoPickerFormFieldState<T> state =
                field as CupertinoPickerFormFieldState<T>;
            final errorBorder = (decoration.border == null)
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffd32f2f)),
                  )
                : decoration.border!.copyWith(
                    borderSide: const BorderSide(color: Color(0xffd32f2f)),
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    await showModalBottomSheet<T>(
                      context: field.context,
                      builder: (_) => _CupertinoPickerModalBottomSheet<T>(
                        key: const ValueKey('_CupertinoPickerModalBottomSheet'),
                        pickedValue: field.value,
                        values: values,
                        valueAsString: valueAsString,
                        onSelectedItemChanged: (index) {
                          field.didChange(values[index]);
                        },
                        onBuildComplete: () {
                          if (field.value == null && values.isNotEmpty) {
                            field.didChange(values[0]);
                          }
                        },
                      ),
                    );
                    if (onPickerClose != null) onPickerClose(field.value);
                  },
                  child: AbsorbPointer(
                    child: Theme(
                      data: field.hasError
                          ? ThemeData().copyWith(
                              colorScheme: ThemeData()
                                  .colorScheme
                                  .copyWith(primary: const Color(0xffd32f2f)),
                              inputDecorationTheme: InputDecorationTheme(
                                enabledBorder: errorBorder,
                              ),
                            )
                          : Theme.of(field.context),
                      child: TextField(
                        controller: state._controller,
                        focusNode: focusNode,
                        enabled: enabled,
                        style: style,
                        decoration: decoration,

                        /// Disable content selection of [TextField]
                        readOnly: true,
                        showCursor: false,
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
            );
          },
        );

  /// Only members declared here are accessible to the
  /// [CupertinoPickerFormFieldState]
  // final Icon resetIcon;
  final String Function(T) valueAsString;

  @override
  FormFieldState<T> createState() => CupertinoPickerFormFieldState<T>();
}

class CupertinoPickerFormFieldState<T> extends FormFieldState<T> {
  final TextEditingController _controller = TextEditingController(text: '');
  // FormField is not scrollable, so don't place the
  // FixedExtentScrollController in here, this belongs to the
  // _CupertinoPickerModalBottomSheet

  // Retype the type of the widget from FormField<T> to
  // CupertinoPickerFormField<T>
  @override
  CupertinoPickerFormField<T> get widget =>
      super.widget as CupertinoPickerFormField<T>;

  bool get hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.valueAsString(widget.initialValue!);
    }
  }

  @override
  void didChange(T? value) {
    super.didChange(value);
    final formattedString = (value != null) ? widget.valueAsString(value) : '';
    if (_controller.text != formattedString) {
      _controller.text = formattedString;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// Clear everything in the [FormField]
  void clear() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _controller.clear();
      didChange(null);
    });
  }

  bool shouldShowClearIcon(InputDecoration decoration) =>
      hasText && decoration.suffixIcon == null;
}

class _CupertinoPickerModalBottomSheet<T> extends StatefulWidget {
  const _CupertinoPickerModalBottomSheet({
    Key? key,
    required this.pickedValue,
    required this.values,
    required this.valueAsString,
    required this.onSelectedItemChanged,
    required this.onBuildComplete,
  }) : super(key: key);

  final T? pickedValue;
  final List<T> values;
  final String Function(T) valueAsString;
  final void Function(int)? onSelectedItemChanged;
  final void Function() onBuildComplete;

  @override
  State<_CupertinoPickerModalBottomSheet<T>> createState() =>
      _CupertinoPickerModalBottomSheetState<T>();
}

class _CupertinoPickerModalBottomSheetState<T>
    extends State<_CupertinoPickerModalBottomSheet<T>> {
  final FixedExtentScrollController _scrollWheelController =
      FixedExtentScrollController(initialItem: 0);

  @override
  void initState() {
    super.initState();

    /// Scroll to the initial item in the [CupertinoPicker]
    if (widget.pickedValue != null) {
      _scrollWheelController
          .jumpToItem(widget.values.indexOf(widget.pickedValue!));
    }
  }

  @override
  Widget build(BuildContext context) {
    /// The cb below only runs when the modal pops up and the
    /// [ListWheelScrollView] backing [CupertinoPicker] has
    /// finished rendering (build method is complete)
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.values.isNotEmpty) {
        _scrollWheelController.jumpToItem(
          widget.pickedValue == null
              ? 0
              : widget.values.indexOf(widget.pickedValue!),
        );
      }
      widget.onBuildComplete();
    });
    return SizedBox(
      height: widget.values.length >= 6 ? 300 : 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: CupertinoPicker.builder(
              /// if [itemExtent] is too low, the content for
              /// each item will be squished together
              itemExtent: 32,
              scrollController: _scrollWheelController,
              onSelectedItemChanged: widget.onSelectedItemChanged,
              childCount: widget.values.length,
              itemBuilder: (_, index) => Center(
                child: Text(
                  widget.valueAsString(widget.values[index]),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollWheelController.dispose();
  }
}
