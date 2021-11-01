import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_state/navigation_service.dart';
import 'screens/login/login_screen.dart';
import 'theme.dart';

const _useFirebaseEmulatorSuite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((_) {
    debugPrint('Cannot initialize Firebase');
  });

  if (_useFirebaseEmulatorSuite) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    /// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    /// This is only called once after the widget is mounted.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => FirebaseAuth.instance.authStateChanges().listen((User? user) {
        // NavigationService.navigatorKey.currentState!
        //     .popUntil((route) => route.isFirst);
        // if (user == null)
        //   NavigationService.navigatorKey.currentState!
        //       .pushReplacementNamed(LoginScreen.routeName);
        // else
        //   NavigationService.navigatorKey.currentState!
        //       .pushReplacementNamed(ExploreScreen.routeName);
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      title: 'Easy Wellness',
      theme: theme(),
      home: const LoginScreen(),
    );
  }
}
