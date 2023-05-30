import 'package:blog/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Background extends ConsumerWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    this.topImage = Constants.loginTopImagePath,
    this.bottomImage = Constants.loginBottomImagePath,
  }) : super(key: key);

  final String topImage, bottomImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  topImage,
                  width: 120,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(bottomImage, width: 120),
              ),
              SafeArea(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
