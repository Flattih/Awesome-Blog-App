import 'dart:io';

import 'package:blog/core/common/common.dart';
import 'package:blog/core/common/large_button.dart';
import 'package:blog/core/common/rounded_text_field.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils.dart';
import '../controller/blog_controller.dart';

class AddTopicScreen extends ConsumerStatefulWidget {
  static const routeName = "/addTopic";
  const AddTopicScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends ConsumerState<AddTopicScreen> {
  File? _image;
  final titlectr = TextEditingController();
  final aciklamactr = TextEditingController();
  @override
  void dispose() {
    titlectr.dispose();
    aciklamactr.dispose();
    super.dispose();
  }

  void pickImage() async {
    final image = await pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void addTopic(String title, String aciklama, File image) {
    ref
        .read(addBlogControllerProvider.notifier)
        .addTopic(title, aciklama, image, context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addBlogControllerProvider);
  
    return SafeArea(
      child: isLoading
          ? const LoadingScreen()
          : Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text("Konu Ekle",
                    style: TextStyle(color: Colors.black)),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      RoundedTextField(
                          prefixIcon: FontAwesomeIcons.marker,
                          hintText: "Başlık",
                          textctr: titlectr),
                      const SizedBox(height: 30),
                      RoundedTextField(
                          prefixIcon: Icons.warning,
                          hintText: "Ufak açıklama",
                          textctr: aciklamactr),
                      const SizedBox(height: 30),
                      const Text("Profillerinde gözükecek fotoğraf",
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      const SizedBox(height: 30),
                      _image == null
                          ? GestureDetector(
                              onTap: pickImage,
                              child: DottedBorder(
                                color: Colors.black87,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        FontAwesomeIcons.image,
                                        size: 40,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        'Resim Ekle',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
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
                      const SizedBox(height: 50),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                            width: context.width * 0.8, height: 55),
                        child: LargeButton(
                            backgroundColor: Colors.black87,
                            padding: EdgeInsets.zero,
                            onTap: () {
                              if (aciklamactr.text.isEmpty ||
                                  titlectr.text.isEmpty ||
                                  _image == null) {
                                showSnackBar(
                                    context: context,
                                    title: "Lütfen tüm alanları doldurun");
                              } else {
                                addTopic(
                                    titlectr.text, aciklamactr.text, _image!);
                              }
                            },
                            text: "Okey",
                            icon: FontAwesomeIcons.check),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
