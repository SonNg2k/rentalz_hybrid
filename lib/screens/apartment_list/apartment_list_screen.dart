import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.menu),
        onPressed: () => FirebaseAuth.instance.signOut(),
      ),
    );
  }
}
