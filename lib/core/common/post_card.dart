import 'dart:convert';
import 'package:blog/features/auth/controller/auth_controller.dart';
import 'package:blog/features/profile/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/core/utils.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../features/blog/screens/comments_screen.dart';
import '../../features/blog/screens/detail_screen.dart';
import '../../models/blog_model.dart';
import '../theme/app_theme.dart';

class PostCard extends ConsumerWidget {
  final Blog blog;
  final bool isExist;
  const PostCard({super.key, required this.blog, this.isExist = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 28.0, top: 12, right: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final user = ref
                          .watch(authControllerProvider.notifier)
                          .getUserData(blog.uid);
                      user.first.then((value) {
                        context.toNamed(ProfileScreen.routeName,
                            arguments: value);
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              blog.profilePictureUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.username,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: ref.watch(themeProvider) ==
                                        AppTheme.darkTheme
                                    ? Colors.teal
                                    : Colors.black),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        timeago.format(blog.createdAt, locale: 'tr'),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color:
                                ref.watch(themeProvider) == AppTheme.darkTheme
                                    ? Colors.teal
                                    : Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              if (ref.read(userProvider)?.isAdmin ?? false) ...[
                IconButton(
                    onPressed: () {
                      ref
                          .read(addBlogControllerProvider.notifier)
                          .deleteBlog(blog, context);
                    },
                    icon: Icon(Icons.delete,
                        color: ref.watch(themeProvider) == AppTheme.darkTheme
                            ? Colors.teal
                            : Colors.black)),
                isExist
                    ? IconButton(
                        onPressed: () async {
                          try {
                            await http.post(
                              Uri.parse('https://fcm.googleapis.com/fcm/send'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization':
                                    'key=AAAA-5yImJQ:APA91bFfWFzxm4Jb9zpE0A3nMI2lkEhqgOA8BVO7Tz-42od8niliDX3YhIut0xDpojXAedGnYKYnNRtVtAnSf_qITwWfaMMwbHTf8UjYOAOSS9JnHgMYvKHzcYipGGKeeRbfFqxfAlUF'
                              },
                              body: jsonEncode(
                                {
                                  'priority': 'high',
                                  'data': {
                                    'click_action':
                                        'FLUTTER_NOTIFICATION_CLICK',
                                    'body': 'message',
                                    'title': 'title',
                                    'status': 'done'
                                  },
                                  'notification': {
                                    'body': "Blogunuz onaylandı",
                                    'title': 'Tebrikler',
                                  },
                                  'to': blog.token,
                                },
                              ),
                            );
                          } catch (e) {
                            awesomeSnackBar(
                                context: context,
                                contentType: ContentType.failure,
                                message: "Bildirim gönderilemedi",
                                title: "Hata");
                          }
                          ref
                              .read(addBlogControllerProvider.notifier)
                              .approveBlog(blog, context);
                        },
                        icon: Icon(Icons.check,
                            color:
                                ref.watch(themeProvider) == AppTheme.darkTheme
                                    ? Colors.teal
                                    : Colors.black))
                    : const SizedBox.shrink(),
              ],
              ref.read(userProvider)?.uid == blog.uid
                  ? IconButton(
                      onPressed: () {
                        ref
                            .read(addBlogControllerProvider.notifier)
                            .deleteBlog(blog, context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: ref.watch(themeProvider) == AppTheme.darkTheme
                            ? Colors.teal
                            : null,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              context.toNamed(DetailScreen.routeName, arguments: blog);
            },
            child: Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(blog.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Text(blog.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                LikeButton(
                  isLiked: blog.likes.contains(ref.watch(userProvider)?.uid),
                  onTap: (isLiked) {
                    ref
                        .read(addBlogControllerProvider.notifier)
                        .likeBlog(blog, context);
                    return Future.value(!isLiked);
                  },
                  size: 30,
                  circleColor: CircleColor(
                      start: ref.watch(themeProvider) == AppTheme.darkTheme
                          ? Colors.teal
                          : context.primaryColor,
                      end: ref.watch(themeProvider) == AppTheme.darkTheme
                          ? Colors.teal
                          : context.primaryColor.withOpacity(0.5)),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor:
                        ref.watch(themeProvider) == AppTheme.darkTheme
                            ? Colors.teal
                            : context.primaryColor.withOpacity(0.2),
                    dotSecondaryColor:
                        ref.watch(themeProvider) == AppTheme.darkTheme
                            ? Colors.teal
                            : context.primaryColor.withOpacity(0.2),
                  ),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.favorite,
                      color: ref.watch(themeProvider) == AppTheme.darkTheme
                          ? isLiked
                              ? Colors.teal
                              : Colors.teal.withOpacity(0.2)
                          : isLiked
                              ? context.primaryColor.withOpacity(0.6)
                              : context.primaryColor.withOpacity(0.2),
                      size: 30,
                    );
                  },
                  likeCount: blog.likeCount,
                  countBuilder: (int? count, bool isLiked, String text) {
                    var color = isLiked ? context.primaryColor : Colors.grey;
                    Widget result;
                    if (blog.likeCount == 0) {
                      result = Text(
                        "İlk beğenen sen ol",
                        style: TextStyle(
                            color:
                                ref.watch(themeProvider) == AppTheme.darkTheme
                                    ? Colors.teal
                                    : color),
                      );
                    } else {
                      result = Text(
                        text,
                        style: TextStyle(
                            color:
                                ref.watch(themeProvider) == AppTheme.darkTheme
                                    ? Colors.teal
                                    : color),
                      );
                    }
                    return result;
                  },
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.toNamed(CommentsScreen.routeName,
                            arguments: blog.id);
                      },
                      child: Icon(
                        FontAwesomeIcons.comment,
                        color: ref.watch(themeProvider) == AppTheme.darkTheme
                            ? Colors.teal
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${blog.commentCount} yorum",
                      style: TextStyle(
                          color: ref.watch(themeProvider) == AppTheme.darkTheme
                              ? Colors.teal
                              : Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
