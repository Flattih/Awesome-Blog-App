import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/features/blog/controller/blog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/rounded_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  TextEditingController adCtr = TextEditingController();
  TextEditingController bioCtr = TextEditingController();
  File? _image;
  selectImage() async {
    final image = await pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  void initState() {
    final user = ref.read(userProvider);
    adCtr.text = user?.name ?? "";
    bioCtr.text = user?.bio ?? "";
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void updateProfile({String? name, String? bio, File? image}) {
    final user = ref.read(userProvider);
    if (name != null || bio != null || image != null) {
      ref.read(addBlogControllerProvider.notifier).editProfile(
          ref: ref,
          context: context,
          user: user!,
          name: name,
          bio: bio,
          profilePic: image);
    } else {
      awesomeSnackBar(
          context: context,
          message: "Lütfen en az bir alanı doldurun",
          contentType: ContentType.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == AppTheme.darkTheme
                  ? Icons.nights_stay_outlined
                  : Icons.wb_sunny_outlined,
              size: 20,
            ),
            color: Colors.green,
            onPressed: () {
              ref.watch(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
        title: const Text(
          "Profilini Düzenle",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: const BackButton(
          color: Colors.green,
        ),
      ),
      body: Visibility(
        visible: ref.watch(addBlogControllerProvider) == false,
        replacement: const Center(
          child: LoaderSpin(color: Colors.red),
        ),
        child: ListView(
          padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
          children: [
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: selectImage,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 10),
                          )
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _image == null
                              ? NetworkImage(
                                  user?.profilePic ??
                                      "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
                                )
                              : FileImage(_image!) as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            RoundedTextField(
                hintText: "Adınız", prefixIcon: Icons.person, textctr: adCtr),
            const SizedBox(
              height: 40,
            ),
            RoundedTextField(
                hintText: "Biyografiniz",
                prefixIcon: Icons.edit,
                textctr: bioCtr),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "İptal",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                        color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                    ),
                  ),
                  onPressed: () => updateProfile(
                      bio: bioCtr.text, name: adCtr.text, image: _image),
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                        color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
