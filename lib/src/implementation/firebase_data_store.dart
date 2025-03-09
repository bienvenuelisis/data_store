import 'package:data_store_impl/data_store_impl.dart';
import 'package:data_store_impl/src/interface/i_data_store.dart';

class FirebaseDataStore extends IDataStore {
  const FirebaseDataStore() : super();
  @override
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
  }) {
    return FirestoreHelpers.createDocument(collectionName, data, id: id);
  }

  @override
  Future<void> deleteDocument(String collectionName, String documentId) {
    return FirestoreHelpers.deleteDocument(collectionName, documentId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String collectionName) {
    return FirestoreHelpers.getAll(collectionName);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    value,
  ) {
    return FirestoreHelpers.getAllWhere(collectionName, field, operator, value);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List> queries,
  ) {
    return FirestoreHelpers.getAllWheres(collectionName, queries);
  }

  @override
  Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  ) {
    return FirestoreHelpers.getDocument(collectionName, documentId);
  }

  @override
  Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return FirestoreHelpers.updateDocument(collectionName, documentId, data);
  }
}
