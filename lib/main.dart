import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alert_service.dart';
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
        _handleEmailLinkLogin(deepLink);
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
    _handleEmailLinkLogin(deepLink);
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
            NavigationService.pushReplacementPage(const LoginScreen());
          } else {
            NavigationService.pushReplacementPage(const ApartmentListScreen());
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

void _handleEmailLinkLogin(Uri? deepLink) async {
  if (deepLink == null) return;
  final userSignedInWithEmailLink =
      await verifyEmailLinkAndLogin(deepLink.toString());
  if (userSignedInWithEmailLink == null) return;

  /// Link the user who is logged in with email auth link to
  /// the Facebook OAuth account...
  final prefs = await SharedPreferences.getInstance();
  final authCredentialString = prefs.getString('authCredentialToLink');
  if (authCredentialString == null) return;

  /// When the user failed to login with their Facebook account due to
  /// duplicate email, the Facebook auth credential is saved to local storage.
  final authCredentialJson = jsonDecode(authCredentialString);
  final authCredentialToLink = AuthCredential(
    providerId: authCredentialJson['providerId'],
    signInMethod: authCredentialJson['signInMethod'],
    token: authCredentialJson['token'],
  );
  await userSignedInWithEmailLink.linkWithCredential(authCredentialToLink);
  AlertService.showPersistentSnackBar(
      'You can now use this Facebook account to login, it is successfully linked to this email.');
  debugPrint('Facebook account is successfully linked to the logged user');
}
