import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blog/core/extensions/context_extension.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(
      context: context,
      title: "Hata",
    );
  }
  return image;
}

void awesomeSnackBar(
    {required BuildContext context,
    String? title,
    String? message,
    Color? color,
    required ContentType contentType}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        color: color,
        title: title ?? "",
        message: message ?? "",

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: contentType,
      ),
    ),
  );
}

void showSnackBar({
  required BuildContext context,
  required String title,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: context.primaryColor.withOpacity(0.2),
      content: Text(title, style: const TextStyle(color: Colors.black)),
    ),
  );
}

/* class DynamicLinkPro {
  Future<String> createLink(String id) async {
    final String url = "https://com.blogappz3.erkam.blog?id=$id";


    final DynamicLinkParameters parameters = DynamicLinkParameters(
        iosParameters:
            const IOSParameters(bundleId: "com.blogappz3.erkam.blog"),
        androidParameters:
            const AndroidParameters(packageName: "com.blogappz3.erkam.blog"),
        link: Uri.parse(url),
        uriPrefix: "https://blogzi.page.link");

    final FirebaseDynamicLinks link = FirebaseDynamicLinks.instance;
    final idLink = await link.buildShortLink(parameters);
    return idLink.shortUrl.toString();
  }

  static initDynamic(BuildContext context) async {
    final instanceLink = await FirebaseDynamicLinks.instance.getInitialLink();
    print(instanceLink);

    if (instanceLink != null) {
      final Uri idLink = instanceLink.link;
      Map<String, dynamic> params = idLink.queryParameters;
      print(params);

      if (params["id"] != null) {
        context.toNamed(FromDynamicLinkScreen.routeName,
            arguments: params["id"]);
      }
    }
  }
}
 */