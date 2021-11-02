import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:rentalz/alert_service.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/services/auth_service/login_with_facebook.service.dart';
import 'package:rentalz/services/auth_service/login_with_google.service.dart';
import 'package:rentalz/services/auth_service/send_sign_in_link_to_email.service.dart';
import 'package:rentalz/utils/check_if_email_is_valid.dart';
import 'package:rentalz/widgets/or_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'send_auth_link_and_verify_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset("assets/icons/waves_bottom.svg"),
            ),
            const Scaffold(
              /// See the white container with waves at the bottom
              backgroundColor: Colors.transparent,
              body: _Body(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Image.asset(
              "assets/images/login.png",
              width: size.width * 0.4,
            ),
            const SizedBox(height: 8),
            const EmailLinkLoginSection(),
            const SizedBox(height: 8),
            const OrDivider(),
            ElevatedButton.icon(
              onPressed: () => loginWithGoogle(),
              style: ElevatedButton.styleFrom(primary: Colors.white60),
              icon: SvgPicture.asset(
                'assets/icons/google_icon.svg',
                height: 24,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => loginWithFacebook(),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              icon: SvgPicture.asset(
                'assets/icons/facebook_icon.svg',
                height: 24,
                color: Colors.white,
              ),
              label: const Text('Continue with Facebook'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailLinkLoginSection extends StatefulWidget {
  const EmailLinkLoginSection({Key? key}) : super(key: key);

  @override
  State<EmailLinkLoginSection> createState() => _EmailLinkLoginSectionState();
}

class _EmailLinkLoginSectionState extends State<EmailLinkLoginSection> {
  final _emailInpController = TextEditingController();

  bool _isEmpty = true;

  Widget get _iosEmailLinkLoginBtn {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
      onPressed: _isEmpty
          ? null
          : () {
              final email = _emailInpController.text;
              final emailErr = checkIfEmailIsValid(email);
              if (emailErr != null) {
                return AlertService.showEphemeralSnackBar(emailErr);
              }
              NavigationService.pushNewPage(
                  SendAuthLinkAndVerifyScreen(email: email));
            },
      child: const Text('Next'),
    );
  }

  Widget get _androidEmailLinkLoginBtn {
    return ElevatedButton.icon(
      icon: const Icon(Icons.insert_link),
      style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
      onPressed: _isEmpty
          ? null
          : () {
              final email = _emailInpController.text;
              final emailErr = checkIfEmailIsValid(email);
              if (emailErr != null) {
                return AlertService.showEphemeralSnackBar(emailErr);
              }

              sendSignInLinkToEmail(email).catchError((e) {
                debugPrint(e);
                AlertService.showEphemeralSnackBar('Sending email failed');
              }).then((_) {
                SharedPreferences.getInstance().then(
                  (prefs) => prefs.setString('emailToAuthViaLink', email),
                );
                showDialog(
                  context: context,
                  builder: (_) {
                    return CupertinoAlertDialog(
                      title: Text('An email has been sent to $email'),
                      content: const Text(
                          'Please tap the link that we sent to your email to sign in.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
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
            },
      label: const Text('Sign in with email link'),
    );
  }

  @override
  void initState() {
    super.initState();
    _emailInpController.addListener(
      () => setState(() => _isEmpty = _emailInpController.text.isEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ThemeData()
                .colorScheme
                .copyWith(primary: Colors.blueGrey[700]!),
          ),
          child: TextField(
            controller: _emailInpController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Your email address',
              prefixIcon: const Icon(Icons.email),
              suffixIcon: _isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _emailInpController.clear(),
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) _iosEmailLinkLoginBtn,
        if (Platform.isAndroid) _androidEmailLinkLoginBtn
      ],
    );
  }

  @override
  void dispose() {
    _emailInpController.dispose();
    super.dispose();
  }
}
