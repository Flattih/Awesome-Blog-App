import 'package:blog/core/common/app_text_field.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/features/auth/screens/components/backgorund.dart';
import 'package:blog/features/auth/screens/components/login_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/large_button.dart';
import '../controller/auth_controller.dart';
import 'auth_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final mailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  void signInWithGoogle() {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context, ref);
  }

  void signInWithEmail() {
    ref.read(authControllerProvider.notifier).signInWithEmail(
        context: context, email: mailCtr.text, password: passwordCtr.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return SafeArea(
      child: Background(
        child: SingleChildScrollView(
          child: isLoading
              ? const Loader()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const WelcomeImage(),
                    Row(
                      children: [
                        const Spacer(),
                        Expanded(
                            flex: 9,
                            child: AppTextField(
                                textctr: mailCtr, hintText: "Email")),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 9,
                          child: AppTextField(
                              textctr: passwordCtr, hintText: "Şifre"),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      child: InkWell(
                        onTap: () {
                          context.toNamed(ForgotPasswordScreen.routeName);
                        },
                        child: Text(
                          "Şifremi unuttum",
                          style: context.textTheme.bodyLarge!.copyWith(
                              color: const Color(0xFF6F35A5),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Hala üye değil misin?",
                          style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white54
                                  : Colors.black54),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () => context.toNamed(SignUpScreen.routeName),
                          child: const Text(
                            "Kayıt ol",
                            style: TextStyle(
                              color: Color(0xFF6F35A5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LargeButton(
                        icon: Icons.login,
                        text: "Giriş yap",
                        onTap: signInWithEmail),
                    const SizedBox(height: 15),
                  ],
                ),
        ),
      ),
    );
  }
}
