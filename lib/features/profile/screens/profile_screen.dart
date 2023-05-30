import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/theme/app_theme.dart';
import 'package:blog/features/auth/controller/auth_controller.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:blog/features/blog/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/user_model.dart';
import 'edit_profile_screen.dart';

class BottomBarProfileScreen extends ConsumerStatefulWidget {
  static const routeName = "/profile/bottombar";
  const BottomBarProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomBarProfileScreenState();
}

class _BottomBarProfileScreenState extends ConsumerState<BottomBarProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = ref.watch(userProvider);

    return Scaffold(
        body: currentUser == null
            ? const Loader()
            : ref.watch(getUserBlogsProvider(currentUser.uid)).when(
                data: (data) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: IconButton(
                          onPressed: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.noHeader,
                              animType: AnimType.rightSlide,
                              title: 'Çıkış Yap',
                              btnCancelText: "İptal",
                              btnOkText: "Çıkış Yap",
                              desc: 'Çıkış yapmak istediğinize emin misiniz?',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                ref
                                    .read(authControllerProvider.notifier)
                                    .logout(context);
                              },
                            ).show();
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(currentUser.profilePic),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          StateColumn(
                                              label: "Takipçi",
                                              count:
                                                  currentUser.followers.length),
                                          StateColumn(
                                              label: "Takip",
                                              count:
                                                  currentUser.following.length),
                                          StateColumn(
                                              label: "Gönderi",
                                              count: data.length),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Consumer(
                                            builder: (context, ref, child) =>
                                                RoundedSmallButton(
                                                    backgroundColor: ref.watch(
                                                                themeProvider) ==
                                                            AppTheme.darkTheme
                                                        ? Colors.white
                                                        : null,
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          EditProfileScreen
                                                              .routeName);
                                                      /*  context.toNamed(
                                                      EditProfileScreen
                                                          .routeName); */
                                                    },
                                                    label: "Profili Düzenle"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Consumer(
                              builder: (context, ref, child) => Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  currentUser.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          color: ref.watch(themeProvider) ==
                                                  AppTheme.darkTheme
                                              ? Colors.white
                                              : null),
                                ),
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) => Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  currentUser.bio,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ref.watch(themeProvider) ==
                                                  AppTheme.darkTheme
                                              ? Colors.white
                                              : null),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) => Divider(
                          color: ref.watch(themeProvider) == AppTheme.darkTheme
                              ? Colors.white
                              : Colors.black,
                          height: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            itemCount: data.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    childAspectRatio: 0.7,
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) {
                              final blog = data[index];
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
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(error: error.toString());
                },
                loading: () {
                  return const Loader();
                },
              ));
  }

  @override
  bool get wantKeepAlive => true;
}

class ProfileScreen extends ConsumerStatefulWidget {
  static const routeName = "/profile";
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    return SafeArea(
      child: Scaffold(
        body: Visibility(
            visible: currentUser != null,
            replacement: const Loader(),
            child: ref.watch(getUserBlogsProvider(widget.user.uid)).when(
                  data: (data) {
                    return ref.watch(getUserDataProvider(widget.user.uid)).when(
                          data: (user) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(
                                                widget.user.profilePic),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    StateColumn(
                                                        label: "Takipçi",
                                                        count: user
                                                            .followers.length),
                                                    StateColumn(
                                                        label: "Takip",
                                                        count: user
                                                            .following.length),
                                                    StateColumn(
                                                        label: "Gönderi",
                                                        count: data.length),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    RoundedSmallButton(
                                                        backgroundColor:
                                                            context.isDarkMode
                                                                ? Colors.white
                                                                : null,
                                                        onTap: () {
                                                          if (currentUser.uid ==
                                                              user.uid) {
                                                            context.toNamed(
                                                                EditProfileScreen
                                                                    .routeName);
                                                          } else {
                                                            ref
                                                                .read(addBlogControllerProvider
                                                                    .notifier)
                                                                .followUser(
                                                                    currentUser
                                                                        .uid,
                                                                    widget.user
                                                                        .uid,
                                                                    context,
                                                                    ref);
                                                          }
                                                        },
                                                        label: currentUser!
                                                                    .uid ==
                                                                user.uid
                                                            ? "Profili Düzenle"
                                                            : user.followers
                                                                    .contains(
                                                                        currentUser
                                                                            .uid)
                                                                ? "Takibi Bırak"
                                                                : 'Takip Et'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          widget.user.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                      : null),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          widget.user.bio,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: context.isDarkMode
                                                      ? Colors.white
                                                      : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  height: 20,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      itemCount: data.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20,
                                              childAspectRatio: 0.7,
                                              crossAxisCount: 3),
                                      itemBuilder: (context, index) {
                                        final blog = data[index];
                                        return GestureDetector(
                                          onTap: () {
                                            context.toNamed(
                                                DetailScreen.routeName,
                                                arguments: blog);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(blog.imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        );
                  },
                  error: (error, stackTrace) {
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                )),
      ),
    );
  }
}

class StateColumn extends StatelessWidget {
  final String label;
  final int count;
  const StateColumn({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: context.isDarkMode ? Colors.white : null),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: context.isDarkMode ? Colors.white : null,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
