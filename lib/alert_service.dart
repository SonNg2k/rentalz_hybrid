import 'package:flutter/material.dart';

import 'navigation_service.dart';

class AlertService {
  /// Making the constructor private to hide this class from the IntelliSense
  /// suggesstions. Constructors of abstract classes are still shown;
  /// therefore, this is not an alternative solution.
  AlertService._();

  static void showEphemeralSnackBar(String message) {
    /// When presenting a SnackBar during a page transition, the SnackBar
    /// completes a Hero animation, moving smoothly to the next page.

    /// The ScaffoldMessenger creates a scope in which all descendant Scaffolds
    /// register to receive SnackBars, which is how they persist across these
    /// transitions. When using the root ScaffoldMessenger provided by the
    /// MaterialApp, all descendant Scaffolds receive SnackBars, unless a new
    /// ScaffoldMessenger scope is created further down the tree. By
    /// instantiating your own ScaffoldMessenger, you can control which
    /// Scaffolds receive SnackBars, and which do not based on the context of
    /// your application.
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  static void showPersistentSnackBar(String message) {
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(days: 365),
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'Close',
            onPressed: () {},
          ),
        ),
      );
  }
}
