import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blog/core/providers/user_provider.dart';
import 'package:blog/features/auth/repo/auth_repo.dart';
import 'package:blog/features/auth/screens/login_screen.dart';
import 'package:blog/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../../models/user_model.dart';

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});
final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
      authRepository: ref.watch(authRepositoryProvider), ref: ref);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);
  Stream<User?> get authStateChange => _authRepository.authStateChange;
  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(ref);
    state = false;
    user.fold(
      (l) {
        showSnackBar(
          title: l.message,
          context: context,
        );
      },
      (userModel) async {
        _ref.read(userProvider.notifier).update((state) => userModel);

        if (userModel.bio == "Henüz bir bio yazılmadı") {
          await AwesomeDialog(
            padding: const EdgeInsets.all(10.0),
            context: context,
            dialogType: DialogType.success,
            btnOkText: "Tamam",
            onDismissCallback: (type) {
              Navigator.pop(context);
            },
            animType: AnimType.rightSlide,
            title: 'Hoşgeldin ${userModel.name}',
            desc:
                'Lütfen profilindeki bionu veya ismini güncelleyerek diğer kullanıcıların seni daha iyi tanımasını sağla.',
          ).show();
        }
        Navigator.pushNamedAndRemoveUntil(
            context, MyHomePage.routeName, (route) => false);
      },
    );
  }

  void signUpWithEmail(
      {required String email,
      required String password,
      required String name,
      required String bio,
      required File profilePic,
      required BuildContext context}) async {
    state = true;
    final userModel = await _authRepository.signUpWithEmail(
        profilePic: profilePic,
        email: email,
        password: password,
        name: name,
        bio: bio);
    state = false;
    userModel.fold((l) => showSnackBar(context: context, title: l.message),
        (user) {
      showSnackBar(
        context: context,
        title: "Tebrikler başarıyla kayıt oldunuz!",
      );
      _ref.read(userProvider.notifier).update((state) => user);
      Navigator.pushNamedAndRemoveUntil(
          context, MyHomePage.routeName, (route) => false);
    });
  }

  signInWithEmail(
      {required String email,
      required String password,
      required BuildContext context}) async {
    state = true;
    final user =
        await _authRepository.signInWithEmail(email: email, password: password);
    state = false;
    user.fold(
        (l) => showSnackBar(
              context: context,
              title: l.message,
            ), (user) {
      _ref.read(userProvider.notifier).update((state) => user);
      showSnackBar(
        context: context,
        title: "Tebrikler giriş yaptınız",
      );
      Navigator.pushNamedAndRemoveUntil(
          context, MyHomePage.routeName, (route) => false);
    });
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logout(BuildContext context) {
    _ref.read(userProvider.notifier).update((state) => null);
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.routeName, (route) => false);
    _authRepository.logOut();
  }

  void resetPassword(String email, BuildContext context) async {
    state = true;
    final result = await _authRepository.forgotPassword(email);
    state = false;
    result.fold((l) {
      showSnackBar(
        context: context,
        title: l.message,
      );
    }, (r) {
      showSnackBar(
        context: context,
        title: "Şifre sıfırlama maili gönderildi",
      );
      Navigator.pop(context);
    });
  }
}
