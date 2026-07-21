import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.red.shade700,

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w300,
      ),
      bodyMedium: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red.shade700,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.red.shade600,

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w300,
      ),
      bodyMedium: TextStyle(color: Colors.black87),
      labelLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.red.shade600,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
