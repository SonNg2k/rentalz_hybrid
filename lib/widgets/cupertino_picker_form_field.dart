/// Author: Son Xuan Nguyen
/// My CupertinoPickerFormField widget in this file is inspired from the
/// TextFormField and DropdownButtonFormField widgets implemented by the
/// Flutter team:
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/text_form_field.dart#L85
/// + https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/dropdown.dart#L1503
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A convenience widget that makes a [CupertinoPicker] into a [FormField].
class CupertinoPickerFormField<T> extends FormField<T> {
  CupertinoPickerFormField({
    // Features
    // this.resetIcon = const Icon(Icons.close),
    // Only properties with [this] belong to this class
    required this.values,
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
            final _CupertinoPickerFormFieldState<T> state =
                field as _CupertinoPickerFormFieldState<T>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    showModalBottomSheet<T>(
                      context: field.context,
                      builder: (_) => _CupertinoPickerModalBottomSheet<T>(
                        key: const ValueKey('_CupertinoPickerModalBottomSheet'),
                        scrollWheelController: state._scrollWheelController,
                        values: values,
                        valueAsString: valueAsString,
                        onSelectedItemChanged: (index) =>
                            field.didChange(values[index]),
                        onBuildComplete: () {
                          state._scrollWheelController.jumpToItem(
                            field.value == null
                                ? 0
                                : values.indexOf(field.value!),
                          );
                          if (field.value == null) field.didChange(values[0]);
                        },
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: state._controller,
                      enabled: enabled,
                      style: style,
                      decoration: decoration,

                      /// Disable content selection of [TextField]
                      readOnly: true,
                      showCursor: false,
                    ),
                  ),
                ),
                Text(
                  field.errorText ?? '',
                  style: Theme.of(field.context)
                      .textTheme
                      .caption!
                      .copyWith(color: Theme.of(field.context).errorColor),
                ),
              ],
            );
          },
        );

  // final Icon resetIcon;
  final List<T> values;
  final String Function(T) valueAsString;

  @override
  FormFieldState<T> createState() => _CupertinoPickerFormFieldState<T>();
}

class _CupertinoPickerFormFieldState<T> extends FormFieldState<T> {
  final TextEditingController _controller = TextEditingController(text: '');
  final FixedExtentScrollController _scrollWheelController =
      FixedExtentScrollController(initialItem: 0);

  // Retype type of widget from [FormField<T>] to [CupertinoPickerFormField<T>]
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

    /// Scroll to the initial item in the [CupertinoPicker]
    if (value != null) {
      _scrollWheelController.jumpToItem(widget.values.indexOf(value!));
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
    _scrollWheelController.dispose();
  }

  /// Invoked by the clear suffix icon to clear everything in the [FormField]
  void clear() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _controller.clear();
      didChange(null);
    });
  }

  bool shouldShowClearIcon(InputDecoration decoration) =>
      hasText && decoration.suffixIcon == null;
}

class _CupertinoPickerModalBottomSheet<T> extends StatelessWidget {
  const _CupertinoPickerModalBottomSheet({
    Key? key,
    required this.scrollWheelController,
    required this.values,
    required this.valueAsString,
    required this.onSelectedItemChanged,
    required this.onBuildComplete,
  }) : super(key: key);

  final FixedExtentScrollController scrollWheelController;
  final List<T> values;
  final String Function(T) valueAsString;
  final void Function(int)? onSelectedItemChanged;
  final void Function() onBuildComplete;

  @override
  Widget build(BuildContext context) {
    /// The cb below only runs when the modal pops up and the
    /// [ListWheelScrollView] backing [CupertinoPicker] has
    /// finished rendering (build method is complete)
    WidgetsBinding.instance!.addPostFrameCallback((_) => onBuildComplete());
    return SizedBox(
      height: 250,
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
              scrollController: scrollWheelController,
              onSelectedItemChanged: onSelectedItemChanged,
              childCount: values.length,
              itemBuilder: (_, index) => Center(
                child: Text(
                  valueAsString(values[index]),
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
}
