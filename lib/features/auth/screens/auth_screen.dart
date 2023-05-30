import 'dart:io';

import 'package:blog/core/common/common.dart';
import 'package:blog/core/common/large_button.dart';
import 'package:blog/core/common/rounded_text_field.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/extensions/string_extension.dart';
import 'package:blog/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<SignUpScreen> {
  File? profPic;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  void signInWithGoogle() {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context, ref);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void selectProfilePic() async {
    final res = await pickImageFromGallery(context);
    setState(() {
      profPic = res;
    });
  }

  void signUpWithMail() async {
    if (!_emailController.text.isValidEmail()) {
      showSnackBar(context: context, title: "Lütfen geçerli bir mail giriniz.");
    } else if (_nameController.text.length < 2) {
      showSnackBar(context: context, title: "Lütfen geçerli bir isim giriniz.");
    } else if (_passwordController.text.length < 6) {
      showSnackBar(
          context: context, title: "Şifreniz en az 6 karakter olmalıdır.");
    } else if (profPic == null) {
      showSnackBar(
          context: context, title: "Lütfen profil fotoğrafınızı seçiniz");
    } else {
      ref.read(authControllerProvider.notifier).signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          bio: _bioController.text,
          profilePic: profPic!,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return SafeArea(
      child: isLoading
          ? const LoadingScreen()
          : Scaffold(
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                context.primaryColor.withOpacity(0.2),
                            radius: 64,
                            child: profPic != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Image.file(
                                      profPic!,
                                      fit: BoxFit.cover,
                                      width: 140,
                                      height: 140,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.black,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: selectProfilePic,
                              icon: const Icon(
                                FontAwesomeIcons.image,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Bir hesap oluşturun',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            RoundedTextField(
                                prefixIcon: Icons.person,
                                hintText: "Kullanıcı adı",
                                textctr: _nameController),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedTextField(
                                prefixIcon: FontAwesomeIcons.pencil,
                                hintText: "Biyografi",
                                textctr: _bioController),
                            const SizedBox(height: 20),
                            RoundedTextField(
                                prefixIcon: Icons.mail,
                                hintText: "Mail adresi",
                                textctr: _emailController),
                            const SizedBox(height: 20),
                            RoundedTextField(
                                prefixIcon: Icons.lock_outline,
                                hintText: "Şifre",
                                textctr: _passwordController),
                            const SizedBox(height: 20),
                            RoundedSmallButton(
                              onTap: signUpWithMail,
                              label: "Kayıt ol",
                              textColor: context.isDarkMode
                                  ? Colors.black
                                  : Colors.black54,
                              backgroundColor: context.isDarkMode
                                  ? Colors.white
                                  : context.primaryColor.withOpacity(0.2),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 5,
                              color: context.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("Ya da",
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black54,
                                fontSize: 16,
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Divider(
                              thickness: 5,
                              color: context.primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LargeButton(
                          iconColor: Colors.black54,
                          icon: FontAwesomeIcons.google,
                          textColor: Colors.black54,
                          backgroundColor: context.isDarkMode
                              ? Colors.white
                              : context.primaryColor.withOpacity(0.2),
                          text: "Google ile giriş yap",
                          onTap: signInWithGoogle),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
