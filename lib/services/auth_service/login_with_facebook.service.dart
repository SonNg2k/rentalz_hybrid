import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:rentalz/navigation_service.dart';

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
  if (authErr.code == 'account-exists-with-different-credential') {
    showDialog(
      context: NavigationService.navigatorKey.currentContext!,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(
              'The email address "${authErr.email}" associated with your Facebook account has already been used by another account'),
          content: const Text(
              'We will send a link to this email address, which will allow you to login and link your Facebook account.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(NavigationService.navigatorKey.currentContext!);
                // pushNewPage(
                //     context,
                //     SendAuthLinkAndVerifyScreen(
                //       email: authErr.email!,
                //       authCredentialToLink: authErr.credential,
                //     ));
              },
              child: const Text('Okay', style: TextStyle(color: Colors.blue)),
            )
          ],
        );
      },
    );
  }
}
