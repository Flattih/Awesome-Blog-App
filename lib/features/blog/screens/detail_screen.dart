import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/features/auth/controller/auth_controller.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:blog/features/profile/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/blog_model.dart';

class DetailScreen extends ConsumerWidget {
  final ScrollController scrollController = ScrollController();

  static const routeName = "/detail";
  final Blog blog;
  DetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            Consumer(
              builder: (context, ref, child) => SliverAppBar(
                actions: [
                  ref.watch(userProvider)!.isAdmin
                      ? IconButton(
                          onPressed: () {
                            ref
                                .read(addBlogControllerProvider.notifier)
                                .deleteBlog(blog, context);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete,color: Colors.green,),
                        )
                      : const SizedBox.shrink()
                ],
                leading: BackButton(
                    color: context.isDarkMode ? Colors.white : Colors.grey),
                floating: true,
                snap: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TyperAnimatedText(
                          blog.title,
                          textStyle: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: CachedNetworkImageProvider(
                              blog.profilePictureUrl,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(blog.username),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.favorite,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${blog.likeCount} Beğeni',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w100,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        height: 160,
                        imageUrl: blog.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: blog.description.split(" ")[0],
                              style: GoogleFonts.notoSerif(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 32)),
                          TextSpan(
                            text:
                                " ${blog.description.substring(blog.description.indexOf(" ") + 1)}",
                            style: GoogleFonts.notoSerif(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              height: 1.7,
                              wordSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
