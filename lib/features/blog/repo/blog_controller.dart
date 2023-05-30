import 'dart:io';

import 'package:blog/core/constants/constants.dart';
import 'package:blog/core/failure.dart';
import 'package:blog/core/providers/firebase_providers.dart';
import 'package:blog/core/type_defs.dart';
import 'package:blog/models/blog_model.dart';
import 'package:blog/models/comment_model.dart';
import 'package:blog/models/topic_model.dart';
import 'package:blog/models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/common_firebase_storage.dart';
import '../../../core/providers/user_provider.dart';

final addBlogRepoProvider = Provider<AddBlogRepo>((ref) {
  return AddBlogRepo(
      firestore: ref.watch(firestoreProvider),
      commonFirebaseStorageRepository:
          (ref.watch(commonFirebaseStorageRepositoryProvider)));
});
final topicProvider = FutureProvider<TopicModel>((ref) {
  return ref.read(addBlogRepoProvider).getTopic();
});

class AddBlogRepo {
  final FirebaseFirestore _firestore;
  final CommonFirebaseStorageRepository _commonFirebaseStorageRepository;
  AddBlogRepo(
      {required FirebaseFirestore firestore,
      required CommonFirebaseStorageRepository commonFirebaseStorageRepository})
      : _firestore = firestore,
        _commonFirebaseStorageRepository = commonFirebaseStorageRepository;

  CollectionReference get _blogsCollection =>
      _firestore.collection(Constants.blogCollection);

  CollectionReference get _topicsCollection =>
      _firestore.collection(Constants.topicCollection);

  CollectionReference get _commentsCollection =>
      _firestore.collection(Constants.commentsCollection);
  CollectionReference get _usersCollection =>
      _firestore.collection(Constants.usersCollection);

  FutureVoid addTopic(String title, String desc, File imgOfTopic) async {
    try {
      final String imgUrl =
          await _commonFirebaseStorageRepository.uploadFileToFirebaseStorage(
              "topics/${const Uuid().v1()}", imgOfTopic);
      await _topicsCollection.doc("topic").set({
        "title": title,
        "desc": desc,
        "imgUrl": imgUrl,
      });

      right(null);
    } on FirebaseException catch (e) {
      left(Failure(e.toString()));
    } catch (e) {
      left(Failure(e.toString()));
    }
    return right(null);
  }

  FutureVoid addBlog(Blog blog) async {
    try {
      _blogsCollection.doc(blog.id).set(blog.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<TopicModel> getTopic() async {
    final res = await _topicsCollection.doc("topic").get();
    return TopicModel.fromMap(res.data()! as Map<String, dynamic>);
  }

  Stream<List<Blog>> getApprovedBlogs() {
    return _blogsCollection
        .where('isApproved', isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) {
      return event.docs
          .map((e) => Blog.fromMap(e.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<Blog>> getUnApprovedBlogs() {
    return _blogsCollection
        .where('isApproved', isEqualTo: false)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) {
      return event.docs
          .map((e) => Blog.fromMap(e.data() as Map<String, dynamic>))
          .toList();
    });
  }

  FutureVoid approveBlog(Blog blog) async {
    try {
      _blogsCollection.doc(blog.id).update({"isApproved": true});
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteBlog(Blog blog) async {
    try {
      _blogsCollection.doc(blog.id).delete();
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid likeBlog(Blog blog, Ref ref) async {
    try {
      if (blog.likes.contains(ref.watch(userProvider)?.uid ?? "x")) {
        _blogsCollection.doc(blog.id).update({
          "likes": FieldValue.arrayRemove([ref.watch(userProvider)?.uid ?? "x"])
        });
        _blogsCollection.doc(blog.id).update({
          "likeCount": FieldValue.increment(-1),
        });
      } else {
        _blogsCollection.doc(blog.id).update({
          "likes": FieldValue.arrayUnion([ref.watch(userProvider)?.uid ?? "x"])
        });
        _blogsCollection.doc(blog.id).update({
          "likeCount": FieldValue.increment(1),
        });
      }
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Blog> getBlogById(String id) {
    return _blogsCollection.doc(id).snapshots().map((event) {
      return Blog.fromMap(event.data()! as Map<String, dynamic>);
    });
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _commentsCollection.doc(comment.id).set(comment.toMap());
      return right(_blogsCollection.doc(comment.blogId).update({
        "commentCount": FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteComment(Comment comment) async {
    try {
      await _commentsCollection.doc(comment.id).delete();
      return right(_blogsCollection.doc(comment.blogId).update({
        "commentCount": FieldValue.increment(-1),
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getComments(String blogId) {
    return _commentsCollection
        .where("blogId", isEqualTo: blogId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) {
      return event.docs
          .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
          .toList();
    });
  }

  FutureVoid saveToken(String token, WidgetRef ref) async {
    try {
      await _usersCollection
          .doc(ref.read(userProvider)?.uid)
          .update({"token": token});
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Blog>> getUserBlogs(String uid) {
    return _blogsCollection
        .where("uid", isEqualTo: uid)
        .where("isApproved", isEqualTo: true)
        .snapshots()
        .map(
      (event) {
        return event.docs
            .map(
              (e) => Blog.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  FutureVoid followUser(
      String uid, String followId, BuildContext context, WidgetRef ref) async {
    try {
      final user = _usersCollection.doc(uid).snapshots().map(
          (user) => UserModel.fromMap(user.data()! as Map<String, dynamic>));
      user.first.then(
        (value) async {
          if (value.following.contains(followId)) {
            await _usersCollection.doc(uid).update(
              {
                "following": FieldValue.arrayRemove([followId])
              },
            );
            await _usersCollection.doc(followId).update(
              {
                "followers": FieldValue.arrayRemove([uid])
              },
            );
            ref.read(userProvider.notifier).update((state) {
              return state!.copyWith(
                following: state.following..remove(followId),
              );
            });
          } else {
            await _usersCollection.doc(uid).update(
              {
                "following": FieldValue.arrayUnion([followId])
              },
            );
            await _usersCollection.doc(followId).update(
              {
                "followers": FieldValue.arrayUnion([uid])
              },
            );
          }
        },
      );
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureVoid editProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
