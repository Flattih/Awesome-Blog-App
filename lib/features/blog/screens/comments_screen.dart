import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:blog/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/blog_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  static const routeName = '/comments';
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen>
    with AutomaticKeepAliveClientMixin {
  final commentController = TextEditingController();
  void addComment(Blog blog) {
    ref.read(addBlogControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), blog: blog);
    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Consumer(builder: (context, ref, child) {
      return Scaffold(
          body: StreamBuilder(
        stream: ref
            .read(addBlogControllerProvider.notifier)
            .getBlogById(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Blog blog = snapshot.data as Blog;
            return Column(
              children: [
                StreamBuilder(
                  stream: ref
                      .read(addBlogControllerProvider.notifier)
                      .fetchBlogComments(widget.postId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Comment> comments = snapshot.data as List<Comment>;
                      return Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const Divider(
                              color: Colors.grey,
                              thickness: 1.3,
                              height: 1,
                            );
                          },
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return Consumer(builder: (context, ref, child) {
                              return ListTile(
                                leading: ref.watch(userProvider)!.uid ==
                                        comments[index].uid
                                    ? IconButton(
                                        onPressed: () {
                                          ref
                                              .read(addBlogControllerProvider
                                                  .notifier)
                                              .deleteComment(
                                                context,
                                                comments[index],
                                              );
                                        },
                                        icon: const Icon(FontAwesomeIcons.trash,
                                            color: Colors.teal),
                                      )
                                    : const SizedBox.shrink(),
                                trailing: Text(
                                  timeago.format(
                                    comments[index].createdAt,
                                    locale: 'tr',
                                  ),
                                  style: TextStyle(
                                      color: context.isDarkMode
                                          ? Colors.teal
                                          : context.primaryColor
                                              .withOpacity(0.3)),
                                ),
                                title: Text(comments[index].text,
                                    style: TextStyle(
                                        color: context.isDarkMode
                                            ? Colors.teal
                                            : null)),
                                subtitle: Text(comments[index].username),
                              );
                            });
                          },
                        ),
                      );
                    } else {
                      return const LoaderSpin();
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            hintText: "Yorumunuzu yazın",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          addComment(blog);
                        },
                        icon: const Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const LoaderSpin();
          }
        },
      ));
    }));
  }

  @override
  bool get wantKeepAlive => true;
}
