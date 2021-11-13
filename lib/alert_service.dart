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

  /// This dialog appears before a potentially dangerous operation is performed.
  /// Have two buttons, one to cancel and one to confirm. Return a [Future]
  /// that complete with [true] when the confirm button is tapped and [false]
  /// when the cancel button is tapped or the dialog is dismissed.
  static Future<bool> showConfirmationDialog({
    Widget? title,
    Widget? content,
    String? confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: NavigationService.navigatorKey.currentContext!,
      builder: (_) => Theme(
        data: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: Colors.black),
          ),
        ),
        child: AlertDialog(
          scrollable: true,
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                  NavigationService.navigatorKey.currentContext!, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                  NavigationService.navigatorKey.currentContext!, true),
              child: Text(confirmText?.toUpperCase() ?? 'CONFIRM'),
            ),
          ],
        ),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    return result ?? false;
  }
}
