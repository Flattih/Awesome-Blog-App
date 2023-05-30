import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/common/post_card.dart';
import 'package:blog/core/constants/constants.dart';

import 'package:blog/core/theme/app_colors.dart';
import 'package:blog/core/theme/app_theme.dart';
import 'package:blog/models/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_provider.dart';

enum BlogType { all, mostLiked }

final blogTypeProvider = StateProvider<BlogType>((ref) {
  return BlogType.all;
});

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Query<Map<String, dynamic>> query1;
  late Query<Map<String, dynamic>> query2;
  @override
  void initState() {
    ref.read(userProvider)!.following.shuffle();

    query1 = FirebaseFirestore.instance
        .collection(Constants.blogCollection)
        .where('isApproved', isEqualTo: true)
        .orderBy('likeCount', descending: true);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    query2 = FirebaseFirestore.instance
        .collection(Constants.blogCollection)
        .where('isApproved', isEqualTo: true)
        .where("uid",
            whereIn: ref.watch(userProvider)!.following.isNotEmpty
                ? ref.watch(userProvider)!.following.length > 10
                    ? ref.watch(userProvider)!.following.sublist(0, 10)
                    : ref.watch(userProvider)!.following
                : ["x"])
        .orderBy('createdAt', descending: true);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ref.watch(themeProvider) == AppTheme.darkTheme
            ? Colors.teal.withOpacity(0.3)
            : AppColors.primaryColor.withOpacity(0.3),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        title: Consumer(builder: (context, refConsumer, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              const Text(
                "Ma'Blog",
                style: TextStyle(letterSpacing: 1.5),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  if (refConsumer.watch(blogTypeProvider) == BlogType.all) {
                    refConsumer
                        .watch(blogTypeProvider.notifier)
                        .update((state) => BlogType.mostLiked);
                  } else {
                    refConsumer
                        .watch(blogTypeProvider.notifier)
                        .update((state) => BlogType.all);
                  }
                },
                child: Text(
                  "Best Blogs",
                  style: TextStyle(
                      color: refConsumer.watch(blogTypeProvider) == BlogType.all
                          ? Colors.black
                          : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )
            ],
          );
        }),
      ),
      body: Consumer(
        builder: (context, refConsumer, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 14.0),
            child: RefreshIndicator(
              color: AppColors.primaryColor.withOpacity(0.3),
              onRefresh: () {
                setState(() {
                  query2 = FirebaseFirestore.instance
                      .collection(Constants.blogCollection)
                      .where('isApproved', isEqualTo: true)
                      .where("uid",
                          whereIn: ref.watch(userProvider)!.following.isNotEmpty
                              ? ref.watch(userProvider)!.following.length > 10
                                  ? ref
                                      .watch(userProvider)!
                                      .following
                                      .sublist(0, 10)
                                  : ref.watch(userProvider)!.following
                              : ["x"])
                      .orderBy('createdAt', descending: true);
                });
                return Future.delayed(const Duration(seconds: 3));
              },
              child: FirestoreListView(
                  emptyBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: RefreshIndicator(
                          onRefresh: () {
                            setState(() {
                              query2 = FirebaseFirestore.instance
                                  .collection(Constants.blogCollection)
                                  .where('isApproved', isEqualTo: true)
                                  .where("uid",
                                      whereIn: ref
                                              .watch(userProvider)!
                                              .following
                                              .isNotEmpty
                                          ? ref
                                                      .watch(userProvider)!
                                                      .following
                                                      .length >
                                                  10
                                              ? ref
                                                  .watch(userProvider)!
                                                  .following
                                                  .sublist(0, 10)
                                              : ref
                                                  .watch(userProvider)!
                                                  .following
                                          : ["x"])
                                  .orderBy('createdAt', descending: true);
                            });
                            return Future.delayed(const Duration(seconds: 3));
                          },
                          child: ListView(
                            children: [
                              AnimatedTextKit(
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ref.watch(themeProvider) ==
                                                AppTheme.darkTheme
                                            ? Colors.white
                                            : Colors.black),
                                    "Burada görülecek bir şey yok,birilerini takip etmeye ne dersin?",
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  pageSize: 5,
                  loadingBuilder: (context) {
                    return const LoaderSpin();
                  },
                  itemBuilder: (context, doc) {
                    final blog = doc.data();

                    return PostCard(
                      blog: blog,
                    );
                  },
                  query:
                      refConsumer.watch(blogTypeProvider) == BlogType.mostLiked
                          ? query1.withConverter(
                              fromFirestore: (snapshot, options) {
                                return Blog.fromMap(snapshot.data()!);
                              },
                              toFirestore: (value, options) {
                                return value.toMap();
                              },
                            )
                          : query2.withConverter(
                              fromFirestore: (snapshot, options) {
                                return Blog.fromMap(snapshot.data()!);
                              },
                              toFirestore: (value, options) {
                                return value.toMap();
                              },
                            )),
            ),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
