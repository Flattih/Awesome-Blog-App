import 'package:blog/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
          color: AppColors.primaryColor.withOpacity(0.2)),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loader(),
    );
  }
}

class LoaderSpin extends StatelessWidget {
  final Color? color;
  final double size;
  const LoaderSpin({super.key, this.color, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitSpinningLines(
        color: color ?? Colors.black,
        size: size,
      ),
    );
  }
}
