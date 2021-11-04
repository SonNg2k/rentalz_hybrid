import 'package:flutter/material.dart';
import 'package:rentalz/screens/apartment_list/flow_menu.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(),
            const FlowMenu(),
          ],
        ),
      ),
    );
  }
}
