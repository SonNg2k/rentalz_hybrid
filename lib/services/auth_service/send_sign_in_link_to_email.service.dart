import 'package:firebase_auth/firebase_auth.dart';

Future<void> sendSignInLinkToEmail(String email) {
  return FirebaseAuth.instance.sendSignInLinkToEmail(
    email: email,
    actionCodeSettings: ActionCodeSettings(
      /// Dynamic Links is "sonxuannguyen.page.link". U will need this value
      /// when you configure your iOS or Android app to detect the incoming
      /// app link, parse the underlying deep link and then complete the
      /// sign-in.
      handleCodeInApp: true,

      /// Redirect the user to this URL if the app is not installed on their
      /// device and the app was not able to be installed.
      url: 'https://gw-mobile-app-dev.web.app/email_link_login',
      iOSBundleId: 'com.sonxuannguyen.rentalz',

      /// Must specify the SHA-1 and SHA-256 of your Android app in the
      /// Firebase Console project settings.
      androidPackageName: 'com.sonxuannguyen.rentalz',
    ),
  );
}
