import 'package:flutter/material.dart';

extension RouterContext on BuildContext {
  toNamed(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(routeName, arguments: arguments);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get height => mediaQuery.size.height;
  double get width => mediaQuery.size.width;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  Color get primaryColor => theme.primaryColor;
  Color get cardColor => theme.cardColor;
  ColorScheme get colors => theme.colorScheme;
  bool get isDarkMode {
    final brightness = theme.brightness;
    return brightness == Brightness.dark;
  }
}
