import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  // cardTheme: const CardTheme(
  //   color: Color(0xFF4996D0),
  //   margin: EdgeInsets.all(8.0),
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.all(Radius.circular(12)),
  //   ),
  // ),
);
