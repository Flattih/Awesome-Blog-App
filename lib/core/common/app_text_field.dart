import 'package:blog/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.textctr,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController textctr;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        hintStyle: TextStyle(
            color: context.isDarkMode ? Colors.white54 : Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(29),
          borderSide: BorderSide(
              width: 2,
              color:
                  context.isDarkMode ? Colors.white54 : context.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(29),
          borderSide: BorderSide(width: 2, color: context.primaryColor),
        ),
      ),
      controller: textctr,
    );
  }
}
