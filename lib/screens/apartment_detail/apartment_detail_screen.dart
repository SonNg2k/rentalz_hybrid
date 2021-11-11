import 'package:flutter/material.dart';

class ApartmentDetailScreen extends StatelessWidget {
  const ApartmentDetailScreen({
    Key? key,
    required this.apartmentId,
  }) : super(key: key);

  final String apartmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
