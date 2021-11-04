import 'package:flutter/material.dart';

// https://stackoverflow.com/questions/59247027/difference-between-accent-color-and-the-main-color-in-flutter
ThemeData theme() {
  return ThemeData(
    primaryColor: Colors.black,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
    ),
    appBarTheme: _appBarTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
        .copyWith(secondary: Colors.deepPurpleAccent),
  );
}

AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    foregroundColor: Colors.black,
  );
}
