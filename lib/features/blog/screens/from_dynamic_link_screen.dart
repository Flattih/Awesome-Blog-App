import 'package:blog/core/common/common.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:blog/features/blog/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FromDynamicLinkScreen extends ConsumerWidget {
  final String id;
  static const routeName = "/fromDynamicLink";
  const FromDynamicLinkScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: ref.watch(getBlogByIdProvider(id)).when(
              data: (data) {
                return DetailScreen(blog: data);
              },
              error: (error, stackTrace) {
                return ErrorText(error: error.toString());
              },
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
