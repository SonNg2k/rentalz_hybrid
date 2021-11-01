import 'package:flutter/material.dart';

/// A Global navigator key shared to all widgets below MaterialApp. This is
/// extremely useful if u want to show a snackbar that does not depend on an
/// ephemeral BuildContext, which might quickly get removed when
/// Navigator.popUntil() is called.
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
