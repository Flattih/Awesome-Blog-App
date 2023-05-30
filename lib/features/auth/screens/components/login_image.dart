import 'package:blog/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "Merhaba\n Blog paylaşmaya hazır mısın?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white60 : Colors.black,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                Constants.loginImagePath,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
