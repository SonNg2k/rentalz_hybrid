import 'package:flutter/material.dart';
import 'package:rentalz/utils/data_validator.dart';
import 'package:rentalz/utils/dvhcvn/dvhcvn_data.dart';
import 'package:rentalz/utils/dvhcvn/dvhcvn_model.dart';
import 'package:rentalz/widgets/clearable_text_form_field.dart';
import 'package:rentalz/widgets/cupertino_picker_form_field.dart';

class InputLocationAddressScreen extends StatefulWidget {
  const InputLocationAddressScreen({Key? key}) : super(key: key);

  @override
  State<InputLocationAddressScreen> createState() =>
      _InputLocationAddressScreenState();
}

class _InputLocationAddressScreenState
    extends State<InputLocationAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provinceOrCityFieldKey =
      GlobalKey<CupertinoPickerFormFieldState<Level1>>();
  final _cityOrDistrictFieldKey =
      GlobalKey<CupertinoPickerFormFieldState<Level2>>();
  final _townOrWardOrCommuneFieldKey =
      GlobalKey<CupertinoPickerFormFieldState<Level3>>();
  Level1? _level1;
  Level2? _level2;
  Level3? _level3;
  String? _route;

  CupertinoPickerFormField<Level1> get _provinceOrCityFormField {
    final sortedLevel1s = [...level1s];
    sortedLevel1s
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return CupertinoPickerFormField<Level1>(
      key: _provinceOrCityFieldKey,
      values: sortedLevel1s,
      valueAsString: (value) => value.name,
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.brightness_1_outlined),
        labelText: "Province or city",
      ),
      onPickerClose: (value) => setState(() {
        if (value != _level1) {
          _level1 = value;
          _level2 = null;
          _level3 = null;
          _cityOrDistrictFieldKey.currentState?.clear();
          _townOrWardOrCommuneFieldKey.currentState?.clear();
        }
      }),
      validator: (value) => DataValidator.required(value),
    );
  }

  CupertinoPickerFormField<Level2> get _cityOrDistrictFormField {
    final sortedLevel2s = [...?_level1?.children];
    sortedLevel2s
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return CupertinoPickerFormField<Level2>(
      key: _cityOrDistrictFieldKey,
      values: sortedLevel2s,
      valueAsString: (value) => value.name,
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.brightness_2_outlined),
        labelText: "City or district",
      ),
      onPickerClose: (value) => setState(() {
        if (value != _level2) {
          _level2 = value;
          _level3 = null;
          _townOrWardOrCommuneFieldKey.currentState?.clear();
        }
      }),
      validator: (value) => DataValidator.required(value),
    );
  }

  CupertinoPickerFormField<Level3> get _townOrWardOrCommuneFormField {
    final sortedLevel3s = [...?_level2?.children];
    sortedLevel3s
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return CupertinoPickerFormField<Level3>(
      key: _townOrWardOrCommuneFieldKey,
      values: sortedLevel3s,
      valueAsString: (value) => value.name,
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.brightness_3_outlined),
        labelText: "Town, ward, or commune",
      ),
      onSaved: (value) => _level3 = value,
    );
  }

  ClearableTextFormField get _routeFormField {
    return ClearableTextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.streetAddress,
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.directions_outlined),
        labelText: "Route name",
      ),
      onSaved: (value) => _route = value,
      validator: (value) =>
          DataValidator.lengthRequired(value, minLength: 3, maxLength: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provide location info'),
          actions: [
            TextButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState?.save();
                  final addressBuilder = StringBuffer();
                  addressBuilder.writeAll([
                    _route,
                    if (_level3 != null) _level3!.name,
                    _level2!.name,
                    _level1!.name,
                  ], ', ');
                  Navigator.pop(
                      context,
                      LocationAddress(
                        level1: _level1!,
                        level2: _level2!,
                        level3: _level3,
                        route: _route!,
                        formattedAddress: addressBuilder.toString(),
                      ));
                }
              },
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
              icon: const Text('Done'),
              label: const Icon(Icons.done),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...[
                    _provinceOrCityFormField,
                    _cityOrDistrictFormField,
                    _townOrWardOrCommuneFormField,
                    _routeFormField,
                  ].expand((widget) => [widget, const SizedBox(height: 16)])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _inputDecoration = InputDecoration(
  filled: true,
);

class LocationAddress {
  const LocationAddress({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.route,
    required this.formattedAddress,
  });
  final Level1 level1;
  final Level2 level2;

  /// Some areas don't have level 3.
  final Level3? level3;
  final String route;
  final String formattedAddress;
}
