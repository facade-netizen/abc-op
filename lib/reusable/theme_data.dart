import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData themeData = ThemeData(
  fontFamily: 'Tahoma',
  fontFamilyFallback: const ['Helvetica', 'sans-serif'],
  primaryColor: primary,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 12, height: 1.25),
    displayMedium: TextStyle(fontSize: 12, height: 1.25),
    displaySmall: TextStyle(fontSize: 12, height: 1.25),
    headlineLarge: TextStyle(fontSize: 12, height: 1.25),
    headlineMedium: TextStyle(fontSize: 12, height: 1.25),
    headlineSmall: TextStyle(fontSize: 12, height: 1.25),
    titleLarge: TextStyle(fontSize: 12, height: 1.25),
    titleMedium: TextStyle(fontSize: 12, height: 1.25),
    titleSmall: TextStyle(fontSize: 12, height: 1.25),
    bodyLarge: TextStyle(fontSize: 12, height: 1.25),
    bodyMedium: TextStyle(fontSize: 12, height: 1.25),
    bodySmall: TextStyle(fontSize: 12, height: 1.25),
    labelLarge: TextStyle(fontSize: 12, height: 1.25),
    labelMedium: TextStyle(fontSize: 12, height: 1.25),
    labelSmall: TextStyle(fontSize: 12, height: 1.25),
  ).apply(bodyColor: black, displayColor: black, decorationColor: black),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    side: BorderSide(color: Colors.grey.shade400),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return primary;
      }
      return Colors.white;
    }),
    checkColor: WidgetStateProperty.all(white),
  ),
  radioTheme: RadioThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.selected) ? blue : grey,
    ),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: MaterialStateProperty.all(grey),
    trackColor: MaterialStateProperty.all(Colors.grey.shade100),
    trackBorderColor: MaterialStateProperty.all(Colors.grey.shade400),
    thumbVisibility: MaterialStateProperty.all(true),
    trackVisibility: MaterialStateProperty.all(true),
    thickness: MaterialStateProperty.all(8),
    radius: const Radius.circular(10),
    minThumbLength: 50,
    crossAxisMargin: 2,
    mainAxisMargin: 2,
    interactive: true,
  ),
);

final ThemeData rangeSelectorTheme = ThemeData(
  datePickerTheme: const DatePickerThemeData(
    headerForegroundColor: littleLightGrey,
    headerBackgroundColor: littleLightGrey,
    rangePickerHeaderForegroundColor: littleLightGrey,
    rangePickerHeaderBackgroundColor: littleLightGrey,
  ),
  iconTheme: const IconThemeData(color: white),
);
