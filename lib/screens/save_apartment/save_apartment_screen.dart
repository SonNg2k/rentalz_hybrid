import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentalz/widgets/clearable_text_form_field.dart';
import 'package:rentalz/widgets/input_formatters/numeric_text_input_formatter.dart';

class SaveApartmentScreen extends StatelessWidget {
  const SaveApartmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Apartment info')),
        body: const SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();

  ClearableTextFormField get _nameFormField {
    return ClearableTextFormField(
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.home_outlined),
        labelText: "Apartment name",
      ),
    );
  }

  ClearableTextFormField get _reporterNameFormField {
    return ClearableTextFormField(
      /// TODO: regex to validate name
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.person_outline),
        labelText: "Reporter's name",
      ),
    );
  }

  ClearableTextFormField get _addressFormField {
    return ClearableTextFormField(
      keyboardType: TextInputType.streetAddress,
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.place_outlined),
        labelText: "Apartment address",
      ),
    );
  }

  ClearableTextFormField get _monthlyRentFormField {
    return ClearableTextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumericTextInputFormatter(),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.attach_money_outlined),
        labelText: "Monthly rent price",
      ),
    );
  }

  ClearableTextFormField get _nBedroomsFormField {
    return ClearableTextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumericTextInputFormatter(),
        LengthLimitingTextInputFormatter(2),
      ],
      decoration: _inputDecoration.copyWith(
        prefixIcon: const Icon(Icons.bed_outlined),
        labelText: "Number of bedrooms",
      ),
    );
  }

  TextFormField get _noteFormField {
    return TextFormField(
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      decoration: _inputDecoration.copyWith(
        labelText: 'Note (optional)',
        alignLabelWithHint: true,
      ),
      minLines: 4, // initial height

      /// If maxLines is set to null, there is no limit to the number of lines.
      /// The field sizes itself to the inner text and the wrap is enabled.
      maxLines: null,
      maxLength: 400,
    );
  }

  ElevatedButton get _formSubmitBtn {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.cloud_done_outlined),
      label: const Text('Submit'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...[
                  _nameFormField,
                  _reporterNameFormField,
                  _addressFormField,
                  _monthlyRentFormField,
                  _nBedroomsFormField,
                  _noteFormField,
                  _formSubmitBtn
                ].expand((widget) => [widget, const SizedBox(height: 16)])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _inputDecoration = InputDecoration(
  filled: true,
  helperText: '',
);