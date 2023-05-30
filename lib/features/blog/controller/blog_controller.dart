import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:blog/core/providers/common_firebase_storage.dart';
import 'package:blog/features/blog/repo/blog_controller.dart';
import 'package:blog/models/blog_model.dart';
import 'package:blog/models/comment_model.dart';
import 'package:blog/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils.dart';

final getUserBlogsProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(addBlogControllerProvider.notifier).getUserBlogs(uid);
});

final getApprovedBlogProvider = StreamProvider<List<Blog>>((ref) {
  return ref.watch(addBlogControllerProvider.notifier).getApprovedBlogs();
});
final getUnApprovedBlogProvider = StreamProvider<List<Blog>>((ref) {
  return ref.watch(addBlogControllerProvider.notifier).getUnApprovedBlogs();
});

final getBlogByIdProvider = StreamProvider.family((ref, String id) {
  return ref.watch(addBlogControllerProvider.notifier).getBlogById(id);
});

final getBlogCommentsProvider = StreamProvider.family((ref, String postId) {
  return ref
      .watch(addBlogControllerProvider.notifier)
      .fetchBlogComments(postId);
});

final addBlogControllerProvider =
    StateNotifierProvider<AddBlogController, bool>((ref) {
  return AddBlogController(
      commonFirebaseStorageRepository:
          ref.watch(commonFirebaseStorageRepositoryProvider),
      addBlogRepo: ref.watch(addBlogRepoProvider),
      ref: ref);
});

class AddBlogController extends StateNotifier<bool> {
  final AddBlogRepo _addBlogRepo;
  final CommonFirebaseStorageRepository _commonFirebaseStorageRepository;
  final Ref _ref;
  AddBlogController({
    required CommonFirebaseStorageRepository commonFirebaseStorageRepository,
    required AddBlogRepo addBlogRepo,
    required Ref ref,
  })  : _addBlogRepo = addBlogRepo,
        _ref = ref,
        _commonFirebaseStorageRepository = commonFirebaseStorageRepository,
        super(false);

  void addTopic(
      String title, String desc, File imgOfTopic, BuildContext context) async {
    state = true;
    final res = await _addBlogRepo.addTopic(title, desc, imgOfTopic);
    state = false;
    res.fold(
        (l) => awesomeSnackBar(
            contentType: ContentType.failure,
            context: context,
            message: l.message), (r) {
      awesomeSnackBar(
          context: context,
          contentType: ContentType.success,
          message: "Şimdi blogunuzun onaylanması için bekleyin.",
          title: "Harika!");
      Navigator.pop(context);
    });
  }

  void addBlog({
    required BuildContext context,
    required String title,
    required String desc,
    required File blogImage,
  }) async {
    state = true;
    final user = _ref.read(userProvider)!;
    String blogId = const Uuid().v1();
    final topic = await _addBlogRepo.getTopic();

    final String imageUrl = await _commonFirebaseStorageRepository
        .uploadFileToFirebaseStorage("blogs/$blogId", blogImage);
    final Blog blog = Blog(
        token: user.fcmToken ?? "",
        imageUrl: imageUrl,
        profilePictureUrl: user.profilePic,
        id: blogId,
        title: title,
        description: desc,
        uid: user.uid,
        profileScreenImg: topic.imgUrl,
        username: user.name,
        topic: topic.title,
        likes: [],
        isApproved: false,
        commentCount: 0,
        likeCount: 0,
        createdAt: DateTime.now());
    final res = await _addBlogRepo.addBlog(blog);
    state = false;
    res.fold(
      (l) => showSnackBar(context: context, title: "Bir hata oluştu."),
      (r) {
        awesomeSnackBar(
            contentType: ContentType.success,
            context: context,
            title: "Başarıyla gönderdin!",
            message: "Şimdi blogunun onaylanmasını bekleyin.");
      },
    );
  }

  Stream<List<Blog>> getApprovedBlogs() {
    return _addBlogRepo.getApprovedBlogs();
  }

  Stream<List<Blog>> getUnApprovedBlogs() {
    return _addBlogRepo.getUnApprovedBlogs();
  }

  Future<void> approveBlog(Blog blog, BuildContext context) async {
    state = true;
    final res = await _addBlogRepo.approveBlog(blog);
    state = false;
    res.fold(
      (l) => awesomeSnackBar(
          context: context,
          contentType: ContentType.failure,
          title: "Hata",
          message: l.message),
      (r) => awesomeSnackBar(
          context: context,
          contentType: ContentType.success,
          title: "Başarılı",
          message: "Blog başarıyla onaylandı."),
    );
  }

  Future<void> deleteBlog(Blog blog, BuildContext context) async {
    state = true;
    final res = await _addBlogRepo.deleteBlog(blog);
    state = false;
    res.fold(
      (l) => awesomeSnackBar(
          context: context,
          contentType: ContentType.failure,
          title: "Hata",
          message: l.message),
      (r) => awesomeSnackBar(
          context: context,
          contentType: ContentType.success,
          title: "Başarılı",
          message: "Blog başarıyla silindi."),
    );
  }

  Future<void> likeBlog(Blog blog, BuildContext context) async {
    final res = await _addBlogRepo.likeBlog(blog, _ref);
    res.fold(
        (l) => awesomeSnackBar(
            context: context,
            contentType: ContentType.failure,
            title: "Hata",
            message: l.message),
        (r) => null);
  }

  Stream<Blog> getBlogById(String blogId) {
    return _addBlogRepo.getBlogById(blogId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Blog blog}) async {
    final user = _ref.read(userProvider);
    String commentId = const Uuid().v1();
    final uid = _ref.read(userProvider)!.uid;
    Comment comment = Comment(
        uid: uid,
        id: commentId,
        text: text,
        blogId: blog.id,
        username: user!.name,
        profilePic: user.profilePic,
        createdAt: DateTime.now());
    final res = await _addBlogRepo.addComment(comment);
    res.fold(
        (l) => awesomeSnackBar(
            context: context,
            contentType: ContentType.failure,
            title: "Hata",
            message: l.message),
        (r) => null);
  }

  Stream<List<Comment>> fetchBlogComments(String blogId) {
    return _addBlogRepo.getComments(blogId);
  }

  void saveToken(String token, WidgetRef ref) async {
    await _addBlogRepo.saveToken(token, ref);
  }

  Stream<List<Blog>> getUserBlogs(String uid) {
    return _addBlogRepo.getUserBlogs(uid);
  }

  Future<void> followUser(
      String uid, String followUid, BuildContext context, WidgetRef ref) async {
    final res = await _addBlogRepo.followUser(uid, followUid, context, ref);

    res.fold(
        (l) => awesomeSnackBar(
            context: context,
            contentType: ContentType.failure,
            title: "Hata",
            message: l.message), (r) {
      if (ref.watch(userProvider)!.following.contains(followUid)) {
        ref.read(userProvider.notifier).update((state) => state!.copyWith(
              following: state.following..remove(followUid),
            ));
      } else {
        ref.read(userProvider.notifier).update((state) => state!.copyWith(
              following: state.following..add(followUid),
            ));
      }
      return null;
    });
  }

  void editProfile(
      {File? profilePic,
      required UserModel user,
      required BuildContext context,
      String? name,
      String? bio,
      required WidgetRef ref}) async {
    state = true;
    String? profilePicUrl;
    if (profilePic != null) {
      profilePicUrl = await _commonFirebaseStorageRepository
          .uploadFileToFirebaseStorage("profilePics/${user.uid}", profilePic);
      user = user.copyWith(profilePic: profilePicUrl);
    }
    if (name != null) {
      user = user.copyWith(name: name);
    }
    if (bio != null) {
      user = user.copyWith(bio: bio);
    }

    final res = await _addBlogRepo.editProfile(user);
    state = false;
    res.fold(
        (l) => awesomeSnackBar(
            context: context,
            contentType: ContentType.failure,
            title: "Hata",
            message: l.message), (r) {
      ref.read(userProvider.notifier).update((state) => state!.copyWith(
          name: user.name,
          bio: user.bio,
          profilePic: user.profilePic,
          uid: user.uid));

      awesomeSnackBar(
          context: context,
          contentType: ContentType.success,
          title: "Başarılı",
          message: "Profil başarıyla güncellendi.");
    });
    Navigator.pop(context);
  }

  Future<void> deleteComment(BuildContext context, Comment comment) async {
    final res = await _addBlogRepo.deleteComment(comment);
    res.fold(
        (l) => awesomeSnackBar(
            context: context,
            contentType: ContentType.failure,
            title: "Hata",
            message: l.message),
        (r) => null);
  }
}
