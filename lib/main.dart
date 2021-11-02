import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import 'navigation_service.dart';
import 'screens/apartment_list/apartment_list_screen.dart';
import 'screens/login/login_screen.dart';
import 'services/auth_service/verify_email_link_and_login.service.dart';
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
  Future<void> _initDynamicLinks() async {
    /// Listeners for link callbacks when the application is active or in
    /// background...
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final deepLink = dynamicLink?.link;
        if (deepLink != null) {
          verifyEmailLinkAndLogin(deepLink.toString());
        }
      },
      onError: (OnLinkErrorException e) async {
        debugPrint('onLinkError');
        debugPrint(e.message);
      },
    );

    /// If your app did not open from a dynamic link, getInitialLink() will
    /// return null.
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;
    if (deepLink != null) {
      verifyEmailLinkAndLogin(deepLink.toString());
    }
  }

  @override
  void initState() {
    /// This is only called once after the widget is mounted.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) {
        _initDynamicLinks();

        /// Assign listener after the SDK is initialized successfully.
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          NavigationService.popAllRoutesExceptFirst();
          if (user == null) {
            NavigationService.pushNewPage(const LoginScreen());
          } else {
            NavigationService.pushNewPage(const ApartmentListScreen());
          }
        });
      },
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
