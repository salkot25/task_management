import 'package:flutter/material.dart';
import 'app_colors.dart';

// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  ).copyWith(
      primary: primaryColor, // Ensure primary color is used explicitly
      secondary: secondaryColor, // Ensure secondary color is used explicitly
      error: errorColor, // Ensure error color is used explicitly
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor, // Use the defined primary color
    foregroundColor: Colors.white, // Text/icon color on AppBar
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ), // AppBar title style
    elevation: 0, // Remove elevation
    centerTitle: false, // Align title to the left
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // Button text color
      backgroundColor: primaryColor, // Button background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Button padding
    ),
  ),
   floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor, // FAB background color
    foregroundColor: Colors.white, // FAB icon color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // FAB rounded shape
    ),
   ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // TextFormField corners
      borderSide: BorderSide.none, // Remove default border
    ),
    filled: true, // Fill background of the field
    fillColor: primaryColor.withAlpha((255 * 0.1).round()), // Using withAlpha for opacity
    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Field content padding
  ),
  cardTheme: const CardThemeData(
    elevation: 4.0, // Card elevation
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)), // Card corners
    ),
    margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Card margin
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14),
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
   colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.dark,
  ).copyWith(
       primary: primaryDarkColor, // Ensure primary dark color is used explicitly
      secondary: secondaryDarkColor, // Ensure secondary dark color is used explicitly
      error: errorDarkColor, // Ensure error dark color is used explicitly
   ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
   appBarTheme: AppBarTheme(
    backgroundColor: greyDarkColor, // Dark mode AppBar color
    foregroundColor: Colors.white, // Text/icon color on AppBar
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ), // AppBar title style
    elevation: 0, // Remove elevation
     centerTitle: false, // Align title to the left
  ),
   elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black, // Button text color
      backgroundColor: primaryDarkColor, // Button background color
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Button padding
    ),
  ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryDarkColor, // FAB background color
    foregroundColor: Colors.black, // FAB icon color
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // FAB rounded shape
    ),
   ),
   inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // TextFormField corners
      borderSide: BorderSide.none, // Remove default border
    ),
    filled: true, // Fill background of the field
    fillColor: primaryDarkColor.withAlpha((255 * 0.3).round()), // Using withAlpha for opacity
     contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Field content padding
  ),
   cardTheme: const CardThemeData(
    elevation: 4.0, // Card elevation
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)), // Card corners
    ),
    margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Card margin
  ),
   textTheme: const TextTheme(
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14),
  ),
);
