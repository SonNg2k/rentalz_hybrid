/// The code for this input formatter is copied from this thread:
/// https://stackoverflow.com/questions/51738935/flutter-using-numberformat-in-textinputformatter
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// This input formatter will remove the zero at the beginning; therefore
/// the string like '0' or '09' never exists. It also adds the thousand
/// separator to the numeric text (e.g. 1,234,567,890).
class NumericTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final numberFormat = NumberFormat("#,###");
      final number = int.parse(
          newValue.text.replaceAll(numberFormat.symbols.GROUP_SEP, ''));
      final newString = (number == 0) ? '' : numberFormat.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
            offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}
