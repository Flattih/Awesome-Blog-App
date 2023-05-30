import 'package:blog/core/common/common.dart';
import 'package:blog/core/common/rounded_text_field.dart';
import 'package:blog/core/extensions/context_extension.dart';
import 'package:blog/core/extensions/string_extension.dart';
import 'package:blog/core/utils.dart';
import 'package:blog/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  static const routeName = '/forgot-password';
  ForgotPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return SafeArea(
      child: isLoading
          ? const LoadingScreen()
          : Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Şifremi Unuttum",
                        style: context.textTheme.displaySmall!.copyWith(
                          color: context.isDarkMode
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      RoundedTextField(
                          prefixIcon: Icons.mail_lock,
                          hintText: "Mail adresiniz",
                          textctr: _emailController),
                      const SizedBox(height: 30),
                      RoundedSmallButton(
                        backgroundColor:
                            context.isDarkMode ? Colors.white : null,
                        textColor:
                            context.isDarkMode ? Colors.black : Colors.black54,
                        label: "Şifremi Sıfırla",
                        onTap: () {
                          if (_emailController.text.isValidEmail()) {
                            ref
                                .read(authControllerProvider.notifier)
                                .resetPassword(_emailController.text, context);
                          } else {
                            showSnackBar(
                                context: context,
                                title:
                                    "Lütfen geçerli bir mail adresi giriniz.");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
