import 'firestore_error.dart';
import 'helpers.dart';

abstract class FirestoreModel<T> {
  String get collectionName;

  String? get id;

  Future<void> delete() async {
    if (id == null) {
      throw FirestoreError('Document ID is null');
    }

    await FirestoreHelpers.deleteDocument(collectionName, id!);
  }

  T fromMap();

  Future<String> save() async {
    return FirestoreHelpers.createDocument(collectionName, toMap(), id: id);
  }

  Map<String, dynamic> toMap();

  Future<void> update() async {
    if (id == null) {
      throw FirestoreError('Document ID is null');
    }

    await FirestoreHelpers.updateDocument(collectionName, id!, toMap());
  }
}
