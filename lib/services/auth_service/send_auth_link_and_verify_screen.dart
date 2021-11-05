import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentalz/alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'send_sign_in_link_to_email.service.dart';
import 'verify_email_link_and_login.service.dart';

/// This screen is only required for the iOS platform because I cannot afford
/// the $99/year Apple Developer Account to use Associated Domains (Firebase
/// Dynamic Links need this built-in iOS capability to setup deep link)
class SendAuthLinkAndVerifyScreen extends StatefulWidget {
  const SendAuthLinkAndVerifyScreen({
    Key? key,
    required this.email,
    this.authCredentialToLink,
  }) : super(key: key);

  final String email;
  final AuthCredential? authCredentialToLink;

  @override
  State<SendAuthLinkAndVerifyScreen> createState() =>
      _SendAuthLinkAndVerifyScreenState();
}

class _SendAuthLinkAndVerifyScreenState
    extends State<SendAuthLinkAndVerifyScreen> {
  final _authLinkInpController = TextEditingController();

  bool _isEmpty = true;

  Widget get _authLinkTextField {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme:
            ThemeData().colorScheme.copyWith(primary: Colors.blueGrey[700]!),
      ),
      child: TextField(
        controller: _authLinkInpController,
        keyboardType: TextInputType.url,
        showCursor: false,
        decoration: InputDecoration(
          hintText: _isEmpty ? 'Link from email' : _authLinkInpController.text,
          suffixIcon: TextButton(
            onPressed: () async {
              final clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData != null && clipboardData.text != null) {
                _authLinkInpController.text = clipboardData.text!;
              }
            },
            child: const Text('Paste'),
          ),
        ),
      ),
    );
  }

  Widget get _verifyAuthLinkAndLoginBtn {
    return ElevatedButton.icon(
      icon: const Icon(Icons.link),
      style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
      onPressed: _isEmpty
          ? null
          : () async {
              final authLink = _authLinkInpController.text;
              if (authLink.trim().isEmpty) {
                _authLinkInpController.clear();
                return AlertService.showEphemeralSnackBar('A link is required');
              }
              final linkIsValid =
                  Uri.tryParse(authLink)?.hasAbsolutePath ?? false;
              if (!linkIsValid) {
                _authLinkInpController.clear();
                return AlertService.showEphemeralSnackBar(
                    'The link is not valid');
              }

              final userSignedInWithEmailLink = await verifyEmailLinkAndLogin(
                _authLinkInpController.text,
                onAuthLinkInvalid: () =>
                    AlertService.showEphemeralSnackBar('The link is not valid'),
              );
              _authLinkInpController.clear();

              /// Link the user who is logged in with email auth link to
              /// the Facebook OAuth account...
              final authCredentialToLink = widget.authCredentialToLink;
              if (userSignedInWithEmailLink == null ||
                  authCredentialToLink == null) return;
              await userSignedInWithEmailLink
                  .linkWithCredential(authCredentialToLink);
              AlertService.showPersistentSnackBar(
                  'You can now use this Facebook account to login, it is successfully linked to this email.');
              debugPrint(
                  'Facebook account is successfully linked to the logged user');
            },
      label: const Text('Sign in with email link'),
    );
  }

  @override
  void initState() {
    _authLinkInpController.addListener(
      () => setState(() => _isEmpty = _authLinkInpController.text.isEmpty),
    );

    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => sendSignInLinkToEmail(widget.email).catchError((e) {
        debugPrint(e);
        AlertService.showEphemeralSnackBar('Sending email failed');
      }).then(
        (_) {
          SharedPreferences.getInstance().then(
            (prefs) => prefs.setString('emailToAuthViaLink', widget.email),
          );
          showDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: Text('An email has been sent to ${widget.email}'),
              content: const Text(
                  'Please copy the link that we sent to your email address. Remember NOT to click this link.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusManager.instance.primaryFocus?.unfocus();

                    /// Open the URL in default browser and
                    /// exit app. Otherwise, the launched
                    /// browser exit along with your app.
                    launch(
                      'https://mail.google.com/mail',
                      forceSafariVC: false,
                    ).catchError((onError) {
                      debugPrint(
                          'Failed to open Gmail on iOS Safari. $onError');
                    });
                  },
                  child: Text(
                    'Okay',
                    style: TextStyle(color: Colors.blueGrey[700]!),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy & Paste the email link'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "A link is sent to your email address",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 32),
            _authLinkTextField,
            const SizedBox(height: 8),
            _verifyAuthLinkAndLoginBtn
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authLinkInpController.dispose();
    super.dispose();
  }
}
