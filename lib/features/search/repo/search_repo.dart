import 'package:blog/core/constants/constants.dart';
import 'package:blog/core/providers/firebase_providers.dart';
import 'package:blog/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchUserProvider = StreamProvider.family((ref, String name) {
  final searchRepo = ref.watch(searchRepoProvider);
  return searchRepo.searchUser(name);
});

final searchRepoProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(firestore: ref.watch(firestoreProvider));
});

class SearchRepository {
  final FirebaseFirestore _firestore;
  SearchRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _userCollection =>
      _firestore.collection(Constants.usersCollection);

  Stream<List<UserModel>> searchUser(String query) {
    return _userCollection
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) => event.docs
            .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
