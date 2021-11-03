import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentalz/alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User?> verifyEmailLinkAndLogin(
  String authLinkSentToEmail, {
  void Function()? onAuthLinkInvalid,
}) async {
  final auth = FirebaseAuth.instance;
  if (!auth.isSignInWithEmailLink(authLinkSentToEmail)) {
    if (onAuthLinkInvalid != null) onAuthLinkInvalid();
    return null;
  }

  /// Retrieve the email from wherever you stored it.
  final prefs = await SharedPreferences.getInstance();
  final emailToAuthViaLink = prefs.getString('emailToAuthViaLink');
  if (emailToAuthViaLink == null) return null;

  try {
    // The client SDK will parse the code from the link for you.
    final identityInfo = await auth.signInWithEmailLink(
        email: emailToAuthViaLink, emailLink: authLinkSentToEmail);
    debugPrint('Successfully signed in with email link!');
    AlertService.showEphemeralSnackBar('Signed in successfully ✅');
    // Additional user profile info *not* available via:
    // identityInfo.additionalUserInfo.profile == null
    // You can check if the user is new or existing:
    // identityInfo.additionalUserInfo.isNewUser;
    return identityInfo.user;
  } catch (onError) {
    String extraMsg = '';
    final error = onError as FirebaseAuthException;
    if (error.code == 'invalid-action-code') {
      extraMsg = '. The link is incorrect, expired, or has already been used.';
    }
    AlertService.showEphemeralSnackBar(
        'Error signing in with email link$extraMsg');
  }
}
