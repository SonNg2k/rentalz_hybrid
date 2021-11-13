import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';

class DataSummary extends StatelessWidget {
  const DataSummary({Key? key, required this.data}) : super(key: key);

  final ApartmentModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
          Text('‣ Apartment name: ${data.name}.'),
          Text("‣ Reporter's name: ${data.reporterName}."),
          Text('‣ Address: ${data.formattedAddress}.'),
          Text('‣ Type: ${data.type.formattedString}.'),
          Text('‣ Comfort level: ${data.comfortLevel.formattedString}.'),
          Text(
              '‣ Monthly rent price: ${NumberFormat("#,###").format(data.monthlyRent)}.'),
          Text('‣ Number of bedrooms: ${data.nBedrooms}.'),
        ].expand((widget) => [widget, const SizedBox(height: 16)])
      ],
    );
  }
}
