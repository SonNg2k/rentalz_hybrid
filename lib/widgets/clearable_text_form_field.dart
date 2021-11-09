/// (Apr 1, 2021) This widget is mostly inspired by the TextFormField widget
/// implemented by the Flutter team:
/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/text_form_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [TextFormField] with a clear button
class ClearableTextFormField extends FormField<String> {
  /// Creates a [FormField] that contains a [TextField].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [TextField] class
  /// and [new TextField], the constructor.
  ClearableTextFormField({
    Key? key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,

    // Features
    this.resetIcon = const Icon(Icons.close),
  })  : assert(initialValue == null || controller == null),
        assert(obscuringCharacter.length == 1),
        assert(
          maxLengthEnforcement == null,
          'maxLengthEnforced is deprecated, use only maxLengthEnforcement',
        ),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        super(
          key: key,
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          enabled: enabled ?? true,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) {
            final _ClearableTextFormFieldState state =
                field as _ClearableTextFormFieldState;
            final InputDecoration effectiveDecoration = decoration
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) onChanged(value);
            }

            return Focus(
              onFocusChange: (hasFocus) => state.setHasFocus(hasFocus),
              child: Theme(
                data: field.hasError
                    ? ThemeData().copyWith(
                        colorScheme: ThemeData()
                            .colorScheme
                            .copyWith(primary: const Color(0xffd32f2f)),
                      )
                    : Theme.of(field.context),
                child: TextField(
                  controller: state._effectiveController,
                  focusNode: focusNode,
                  decoration: effectiveDecoration.copyWith(
                    errorText: field.errorText,
                    suffixIcon:
                        ((field.value?.length ?? -1) > 0 && state.hasFocus)
                            ? IconButton(
                                icon: resetIcon,
                                onPressed: () => state.clear(),
                                color: Theme.of(state.context).hintColor,
                              )
                            : null,
                  ),
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  style: style,
                  strutStyle: strutStyle,
                  textAlign: textAlign,
                  textAlignVertical: textAlignVertical,
                  textDirection: textDirection,
                  textCapitalization: textCapitalization,
                  autofocus: autofocus,
                  toolbarOptions: toolbarOptions,
                  readOnly: readOnly,
                  showCursor: showCursor,
                  obscuringCharacter: obscuringCharacter,
                  obscureText: obscureText,
                  autocorrect: autocorrect,
                  smartDashesType: smartDashesType ??
                      (obscureText
                          ? SmartDashesType.disabled
                          : SmartDashesType.enabled),
                  smartQuotesType: smartQuotesType ??
                      (obscureText
                          ? SmartQuotesType.disabled
                          : SmartQuotesType.enabled),
                  enableSuggestions: enableSuggestions,
                  maxLengthEnforcement: maxLengthEnforcement,
                  maxLines: maxLines,
                  minLines: minLines,
                  expands: expands,
                  maxLength: maxLength,
                  onChanged: onChangedHandler,
                  onTap: onTap,
                  onEditingComplete: onEditingComplete,
                  onSubmitted: onFieldSubmitted,
                  inputFormatters: inputFormatters,
                  enabled: enabled ?? true,
                  cursorWidth: cursorWidth,
                  cursorHeight: cursorHeight,
                  cursorRadius: cursorRadius,
                  cursorColor: cursorColor,
                  scrollPadding: scrollPadding,
                  scrollPhysics: scrollPhysics,
                  keyboardAppearance: keyboardAppearance,
                  enableInteractiveSelection: enableInteractiveSelection,
                  selectionControls: selectionControls,
                  buildCounter: buildCounter,
                  autofillHints: autofillHints,
                  scrollController: scrollController,
                ),
              ),
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;
  final Icon resetIcon;

  @override
  _ClearableTextFormFieldState createState() => _ClearableTextFormFieldState();
}

class _ClearableTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;
  bool hasFocus = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  ClearableTextFormField get widget => super.widget as ClearableTextFormField;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(ClearableTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller!.value);
      }
      if (widget.controller != null) {
        setValue(widget.controller!.text);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void setHasFocus(bool b) => setState(() => hasFocus = b);

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }

  /// Invoked by the clear suffix icon to clear everything in the [FormField]
  void clear() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      didChange(null);
      _effectiveController.clear();
    });
  }
}
