import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/core/theme/app_theme.dart';
import 'package:blog/features/blog/repo/blog_controller.dart';
import 'package:blog/features/blog/screens/add_topic_screen.dart';
import 'package:blog/features/blog/screens/approve_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils.dart';
import '../controller/blog_controller.dart';
import 'package:http/http.dart' as http;

class AddBlogScreen extends ConsumerStatefulWidget {
  static const String routeName = '/addBlog';
  const AddBlogScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends ConsumerState<AddBlogScreen>
    with AutomaticKeepAliveClientMixin {
  String? myToken = "";

  File? _image;
  TextEditingController titlectr = TextEditingController();
  TextEditingController aciklamactr = TextEditingController();
  @override
  void dispose() {
    titlectr.dispose();
    aciklamactr.dispose();
    super.dispose();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void sendPushMessage(String message, String token) async {
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
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'body': 'message',
              'title': 'title',
              'status': 'done'
            },
            'notification': {
              'body': message,
              'title': 'Tebrikler',
            },
            'to': token
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
  }

  pickImage() async {
    final image = await pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void addBlog() {
    if (_image == null || titlectr.text.isEmpty || aciklamactr.text.isEmpty) {
      awesomeSnackBar(
          color: Colors.brown,
          context: context,
          contentType: ContentType.warning,
          message: "Lütfen tüm alanları doldurun",
          title: "Uyarı");
    } else {
      ref.read(addBlogControllerProvider.notifier).addBlog(
          blogImage: _image!,
          context: context,
          title: titlectr.text,
          desc: aciklamactr.text);
      setState(() {
        _image = null;
        titlectr.text = "";
        aciklamactr.text = "";
      });
    }
  }

  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.brown[400],
      appBar: ref.read(userProvider)?.isAdmin ?? false
          ? AppBar(
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  onPressed: () {
                    context.toNamed(ApproveBlogScreen.routeName);
                  },
                  child: const Text("Onaylama"),
                ),
              ],
              centerTitle: false,
              title: TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.teal),
                onPressed: () {
                  context.toNamed(AddTopicScreen.routeName);
                },
                child: const Text("Konu Ekle"),
              ),
            )
          : null,
      body: ref.watch(topicProvider).when(
            data: (data) {
              return SingleChildScrollView(
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) => Column(
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: AnimatedTextKit(
                            totalRepeatCount: 2,
                            animatedTexts: [
                              ColorizeAnimatedText(
                                colors: [
                                  Colors.greenAccent,
                                  Colors.deepPurple,
                                  Colors.deepOrange,
                                  Colors.lightBlueAccent,
                                  Colors.redAccent,
                                  Colors.cyan,
                                ],
                                textStyle: context.textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                                "Haftanın konusu: ${data.title}",
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: context.width * 0.8,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                ref.watch(themeProvider) == AppTheme.darkTheme
                                    ? Colors.teal.withOpacity(0.5)
                                    : Colors.brown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AnimatedTextKit(
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                            animatedTexts: [
                              TyperAnimatedText(
                                speed: const Duration(milliseconds: 50),
                                textStyle: TextStyle(
                                    color: ref.watch(themeProvider) ==
                                            AppTheme.darkTheme
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                data.desc,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.width * 0.8,
                          child: TextField(
                            cursorColor: Colors.brown,
                            maxLines: null,
                            controller: titlectr,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  ref.watch(themeProvider) == AppTheme.darkTheme
                                      ? Colors.teal.withOpacity(0.5)
                                      : Colors.brown.withOpacity(0.2),
                              suffixIcon: Icon(FontAwesomeIcons.featherPointed),
                              hintText: "Başlık",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: context.width * 0.8,
                          child: TextField(
                            maxLines: null,
                            controller: aciklamactr,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  ref.watch(themeProvider) == AppTheme.darkTheme
                                      ? Colors.teal.withOpacity(0.5)
                                      : Colors.brown.withOpacity(0.2),
                              suffixIcon: Icon(
                                FontAwesomeIcons.scroll,
                              ),
                              hintText: "İçerik",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _image == null
                            ? GestureDetector(
                                onTap: pickImage,
                                child: DottedBorder(
                                  color: ref.watch(themeProvider) ==
                                          AppTheme.darkTheme
                                      ? Colors.teal
                                      : Colors.brown,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  child: Container(
                                    width: context.width * 0.8,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.folder_open,
                                          size: 40,
                                          color: ref.watch(themeProvider) ==
                                                  AppTheme.darkTheme
                                              ? Colors.teal
                                              : Colors.brown,
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                          'Resim Ekle',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: ref.watch(themeProvider) ==
                                                    AppTheme.darkTheme
                                                ? Colors.teal
                                                : Colors.brown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: context.width * 0.8,
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 30),
                        Consumer(builder: (context, ref, child) {
                          final isLoading =
                              ref.watch(addBlogControllerProvider);
                          return isLoading
                              ? const Loader()
                              : RoundedSmallButton(
                                  onTap: addBlog,
                                  label: "Yayınla",
                                  backgroundColor: ref.watch(themeProvider) ==
                                          AppTheme.darkTheme
                                      ? Colors.teal.withOpacity(0.5)
                                      : Colors.brown.withOpacity(0.2),
                                );
                        }),
                        SizedBox(height: context.height * 0.3),
                      ],
                    ),
                  ),
                ),
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => Center(
              child: CircularProgressIndicator(
                color: context.primaryColor,
              ),
            ),
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
