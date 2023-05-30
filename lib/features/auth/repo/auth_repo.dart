import 'dart:io';

import 'package:blog/core/constants/constants.dart';
import 'package:blog/core/providers/common_firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';
import '../../../models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    commonFirebaseStorageRepository:
        ref.watch(commonFirebaseStorageRepositoryProvider),
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(authProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final CommonFirebaseStorageRepository _commonFirebaseStorageRepository;

  AuthRepository({
    required FirebaseFirestore firestore,
    required CommonFirebaseStorageRepository commonFirebaseStorageRepository,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _commonFirebaseStorageRepository = commonFirebaseStorageRepository,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(Constants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(WidgetRef ref) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        var username = await _firestore
            .collection(Constants.usersCollection)
            .where("name", isEqualTo: userCredential.user!.displayName)
            .get();
        if (username.docs.isNotEmpty) {
          return left(const Failure("Bu kullanıcı adı zaten alınmış"));
        }
        final String? token = await FirebaseMessaging.instance.getToken();
        userModel = UserModel(
          bio: "Henüz bir bio yazılmadı",
          followers: [],
          following: [],
          isAdmin: false,
          fcmToken: token ?? "",
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? "Yeni Blogger",
          profilePic:
              userCredential.user!.photoURL ?? Constants.profilePicDefault,
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signUpWithEmail({
    required String email,
    required String bio,
    required File profilePic,
    required String password,
    required String name,
  }) async {
    try {
      var username = await _firestore
          .collection(Constants.usersCollection)
          .where("name", isEqualTo: name)
          .get();
      if (username.docs.isNotEmpty) {
        return left(const Failure("Bu kullanıcı adı zaten alınmış"));
      }
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final String? token = await FirebaseMessaging.instance.getToken();
      final UserModel userModel = UserModel(
          bio: bio,
          followers: [],
          following: [],
          isAdmin: false,
          fcmToken: token,
          uid: credential.user!.uid,
          name: name.isEmpty ? "Benim biyografim henüz yok" : name,
          profilePic: credential.user!.photoURL ?? Constants.profilePicDefault);
      final String photoUrl =
          await _commonFirebaseStorageRepository.uploadFileToFirebaseStorage(
              "profile_pics/${credential.user!.uid}", profilePic);
      userModel.copyWith(profilePic: photoUrl);

      await _firestore
          .collection(Constants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toMap());
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInWithEmail(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return right(await getUserData(_auth.currentUser!.uid).first);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    _users.doc(uid).snapshots().listen((event) {});
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data()! as Map<String, dynamic>),
        );
  }

  void logOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  FutureVoid forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
