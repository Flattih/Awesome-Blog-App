import 'dart:math';

import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/features/blog/screens/detail_screen.dart';
import 'package:blog/features/profile/screens/profile_screen.dart';
import 'package:blog/models/blog_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../core/constants/constants.dart';
import '../repo/search_repo.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = '/search';
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final textController = TextEditingController();
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFF9ACD9F),
      appBar: AppBar(
        toolbarHeight: 70,
        title: SearchInput(
            onSufficIconPressed: () {
              setState(() {
                isSearching = false;
                textController.clear();
              });
            },
            textController: textController,
            onSubmitted: (p0) {
              setState(() {
                isSearching = true;
              });
            },
            hintText: "Blogger ara"),
      ),
      body: isSearching
          ? ref.watch(searchUserProvider(textController.text)).when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final user = data[index];

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        onTap: () {
                          context.toNamed(ProfileScreen.routeName,
                              arguments: user);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tileColor: Colors.white70,
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            user.profilePic,
                            errorListener: () {
                              print("Hata");
                            },
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.bio),
                      ),
                    );
                  },
                );
              },
              loading: () => const Loader(),
              error: (error, stack) => const Center(child: Text("Hata")))
          : FirestoreQueryBuilder(
              query: FirebaseFirestore.instance
                  .collection(Constants.blogCollection)
                  .where('isApproved', isEqualTo: true)
                  .orderBy('createdAt', descending: true)
                  .withConverter(
                fromFirestore: (snapshot, options) {
                  return Blog.fromMap(snapshot.data()!);
                },
                toFirestore: (value, options) {
                  return value.toMap();
                },
              ),
              builder: (context, snapshot, child) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Hata"),
                  );
                }
                if (snapshot.isFetching == ConnectionState.waiting) {
                  return const Loader();
                } else if (snapshot.hasData && snapshot.docs.isEmpty) {
                  return const Center(
                    child: Text("Henüz blog yok"),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                    child: LiquidPullToRefresh(
                      color: Color(0xFF9ACD9F),
                      onRefresh: () {
                        return Future.delayed(const Duration(seconds: 1));
                      },
                      child: GridView.builder(
                        itemCount: snapshot.docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 40,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final blog = snapshot.docs[index].data();

                          if (snapshot.hasMore &&
                              index + 1 == snapshot.docs.length) {
                            snapshot.fetchMore();

                            snapshot.docs.shuffle();
                          }
                          return GestureDetector(
                            onTap: () {
                              context.toNamed(DetailScreen.routeName,
                                  arguments: blog);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(blog.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  blog.topic,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchInput extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final Function(String)? onSubmitted;
  final VoidCallback onSufficIconPressed;
  const SearchInput(
      {required this.textController,
      required this.onSufficIconPressed,
      required this.onSubmitted,
      required this.hintText,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            offset: const Offset(12, 26),
            blurRadius: 50,
            spreadRadius: 0,
            color: Colors.grey.withOpacity(.1)),
      ]),
      child: TextField(
        onSubmitted: onSubmitted,
        controller: textController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: onSufficIconPressed,
            icon: Icon(
              Icons.close,
              color: Color(0xFF9ACD9F),
            ),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9ACD9F),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
      ),
    );
  }
}
