import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:rentalz/alert_service.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/screens/login/send_auth_link_and_verify_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'send_sign_in_link_to_email.service.dart';

Future<UserCredential?> loginWithFacebook() async {
  // by default we request the email and the public profile...
  final LoginResult result = await FacebookAuth.instance.login();
  final AccessToken? accessToken = result.accessToken;
  if (accessToken == null) return null;
  final facebookAuthCredential =
      FacebookAuthProvider.credential(accessToken.token);

  try {
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  } catch (err) {
    debugPrint('Failed to login with Facebook');
    _authExceptionHandler(err as FirebaseAuthException);
  }
}

void _authExceptionHandler(FirebaseAuthException authErr) {
  final accountEmail = authErr.email;
  final authCredential = authErr.credential;
  if (authErr.code != 'account-exists-with-different-credential' ||
      accountEmail == null ||
      authCredential == null) return;
  showDialog(
    context: NavigationService.navigatorKey.currentContext!,
    builder: (_) {
      return CupertinoAlertDialog(
        title: Text(
            'The email address "$accountEmail" associated with your Facebook account has already been used by another account'),
        content: const Text(
            'We will send a link to this email address, which will allow you to login and link your Facebook account.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(NavigationService.navigatorKey.currentContext!);

              /// Dynamic Links doesn't work on iOS...
              if (Platform.isIOS) {
                NavigationService.pushNewPage(SendAuthLinkAndVerifyScreen(
                  email: accountEmail,
                  authCredentialToLink: authCredential,
                ));
              }

              /// Dynamic Links work perfectly on Android...
              if (Platform.isAndroid) {
                sendSignInLinkToEmail(accountEmail).catchError((e) {
                  debugPrint(e);
                  AlertService.showEphemeralSnackBar('Sending email failed');
                }).then((_) {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString('emailToAuthViaLink', accountEmail);
                    prefs.setString('authCredentialToLink',
                        jsonEncode(authCredential.asMap()));
                  });
                  showDialog(
                    context: NavigationService.navigatorKey.currentContext!,
                    builder: (_) {
                      return CupertinoAlertDialog(
                        title: Text('An email has been sent to $accountEmail'),
                        content: const Text(
                            'Please tap the link that we sent to your email to sign in.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(NavigationService
                                  .navigatorKey.currentContext!);
                              FocusManager.instance.primaryFocus?.unfocus();
                              OpenMailApp.openMailApp();
                            },
                            child: Text(
                              'Okay',
                              style: TextStyle(color: Colors.blueGrey[700]!),
                            ),
                          )
                        ],
                      );
                    },
                  );
                });
              }
            },
            child: const Text('Okay', style: TextStyle(color: Colors.blue)),
          )
        ],
      );
    },
  );
}
