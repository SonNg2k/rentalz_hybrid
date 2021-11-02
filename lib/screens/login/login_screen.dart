import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rentalz/services/auth_service/login_with_facebook.service.dart';
import 'package:rentalz/services/auth_service/login_with_google.service.dart';
import 'package:rentalz/widgets/or_divider.dart';

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
            Image.asset(
              "assets/images/login.png",
              width: size.width * 0.4,
            ),
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
              onPressed: () => loginWithFacebook(context),
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
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
        //   onPressed: _isEmpty
        //       ? null
        //       : () {
        //           final email = _emailInpController.text;
        //           final emailErr = checkIfEmailIsValid(email);
        //           if (emailErr != null)
        //             return showCustomSnackBar(context, emailErr);
        //           pushNewPage<void>(
        //               context, SendAuthLinkAndVerifyScreen(email: email));
        //         },
        //   child: const Text('Next'),
        // ),
      ],
    );
  }

  @override
  void dispose() {
    _emailInpController.dispose();
    super.dispose();
  }
}
