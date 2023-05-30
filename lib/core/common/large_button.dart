import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LargeButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final EdgeInsets? padding;

  const LargeButton({
    Key? key,
    required this.onTap,
    this.padding,
    required this.text,
    this.iconColor,
    this.textColor,
    this.backgroundColor = const Color(0xFF6F35A5),
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding != null
          ? padding!
          : const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          shape: const StadiumBorder(),
          maximumSize: const Size(double.infinity, 56),
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: FaIcon(
                icon,
                color: iconColor,
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
