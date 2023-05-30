import 'package:blog/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final IconData? prefixIcon, suffixIcon;
  final String hintText;
  final TextEditingController textctr;

  const RoundedTextField({
    Key? key,
    required this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    required this.textctr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textctr,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.isDarkMode
            ? Colors.white
            : context.primaryColor.withOpacity(0.2),
        prefixIcon: Icon(prefixIcon, color: context.primaryColor),
        suffixIcon: Icon(suffixIcon),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(29),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(29),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.black : Colors.black54),
      ),
    );
  }
}
