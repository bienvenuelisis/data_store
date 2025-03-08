import 'helpers.dart';
import 'localstore_error.dart';

abstract class LocalstoreModel<T> {
  String get collectionName;
  String? get id;

  Future<void> delete() async {
    if (id == null) {
      throw LocalstoreError('Document ID is null');
    }

    await LocalstoreHelpers.deleteDocument(collectionName, id!);
  }

  T fromMap();

  Future<String> save() async {
    return LocalstoreHelpers.createDocument(collectionName, toMap(), id: id);
  }

  Map<String, dynamic> toMap();

  Future<void> update() async {
    if (id == null) {
      throw LocalstoreError('Document ID is null');
    }

    await LocalstoreHelpers.updateDocument(collectionName, id!, toMap());
  }
}
