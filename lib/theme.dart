import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  colorScheme: ColorScheme(
    primary: Color(0xFFF9DE34), // You can define a variant if needed
    secondary: Color(0xFFF9DE34), // Accent color variant
    surface: Color(0xFFFFFFFF), // Surface color
    background: Color(0xFFD94432), // Background color
    error: Colors.red, // Error color
    onPrimary: Color(0xFFF9DE34), // Text/icon color on primary
    onSecondary: Color(0xFF000000), // Text/icon color on secondary
    onSurface: Color(0xFF000000), // Text color on surface
    onBackground: Color(0xFFF9DE34), // Text color on background
    onError: Colors.white, // Text color on error
    brightness: Brightness.dark, // Theme brightness (light or dark)
  ),
  fontFamily: 'Roboto',
);
