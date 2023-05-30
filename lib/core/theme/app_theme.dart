import 'package:blog/core/providers/shared_pref_provider.dart';
import 'package:blog/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final themeProvider = StateNotifierProvider<AppTheme, ThemeData>((ref) {
  return AppTheme(ref: ref);
});

class AppTheme extends StateNotifier<ThemeData> {
  final Ref ref;
  AppTheme({required this.ref}) : super(lightTheme) {
    getTheme();
  }

  static ThemeData lightTheme = ThemeData.light().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      suffixIconColor: Colors.brown,
      filled: true,
      fillColor: Colors.white54,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    primaryColor: AppColors.primaryColor,
    appBarTheme: const AppBarTheme(
      toolbarTextStyle: TextStyle(color: Colors.black),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: GoogleFonts.rubikTextTheme(),
  );
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.teal,
    inputDecorationTheme: InputDecorationTheme(
      suffixIconColor: Colors.white,
      filled: true,
      fillColor: Colors.black54,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    textTheme: GoogleFonts.notoSerifTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  void getTheme() {
    final theme = ref.watch(sharedPreferencesProvider).getString('theme');

    if (theme == 'dark') {
      state = darkTheme;
    } else {
      state = lightTheme;
    }
  }

  void toggleTheme() async {
    if (state == darkTheme) {
      await ref.watch(sharedPreferencesProvider).setString('theme', 'light');
      state = lightTheme;
    } else {
      await ref.watch(sharedPreferencesProvider).setString('theme', 'dark');
      state = darkTheme;
    }
  }
}
