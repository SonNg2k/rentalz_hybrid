import 'package:flutter/material.dart';

ThemeData theme() {
  /// Themes are actually instances of ThemeData.
  /// https://api.flutter.dev/flutter/material/ThemeData-class.html
  return ThemeData(
    primaryColor: Colors.black,

    /// The most important attributes are `colorScheme` (u may also know this
    /// param by its alter ego, `primarySwatch`) and `textTheme` (used to
    /// control your app's text).
    ///
    /// Use MaterialColors to set whole color palettes.
    /// There are a host of other color params that affect various parts of
    /// your app and these often draw default values from your `colorScheme`.
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
        .copyWith(secondary: Colors.deepPurpleAccent),
    // textTheme: GoogleFonts.emilysCandyTextTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,

    /// The rest of the `ThemeData` class is a composition of many smaller
    /// themes stiched together (sub themes)...
    ///
    /// If u want to modify just a portion of your UI, use the
    /// `Theme(data: ThemeData(...), child: Widget())` widget. U can also copy
    /// your existing theme and bend it to your will with
    /// `Theme(data: Theme.of(context).copyWith(...), child: Widget())`
    /// Whenever u write Theme.of(context), Flutter will scour your widget tree
    /// for the first ThemeData() it finds and then stops right there.

    appBarTheme: _appBarTheme(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        /// Use the `primary` param to override the default text and icon
        /// colors for a `TextButton`, as well as its overlay color, with all
        /// of the standard opacity adjustments for the pressed, focused,
        /// and hovered states
        primary: Colors.black,
        backgroundColor: Colors.grey[200],
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    ),
  );
}

AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    foregroundColor: Colors.black,
  );
}
