import 'package:blog/core/common/common.dart';
import 'package:blog/core/common/post_card.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:blog/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApproveBlogScreen extends ConsumerStatefulWidget {
  static const routeName = '/approve-blog';
  const ApproveBlogScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ApproveBlogState();
}

class _ApproveBlogState extends ConsumerState<ApproveBlogScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ref.watch(getUnApprovedBlogProvider).when(
                  data: (data) {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          Blog blog = data[index];
                          return PostCard(
                            blog: blog,
                            isExist: true,
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => const LoaderSpin(),
                ),
          ],
        ),
      ),
    );
  }
}
