import 'package:data_store_impl/data_store_impl.dart';
import 'package:data_store_impl/src/interface/i_data_store.dart';

class LocalDataStore extends IDataStore {
  const LocalDataStore() : super();

  @override
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
  }) {
    return LocalstoreHelpers.createDocument(collectionName, data, id: id);
  }

  @override
  Future<void> deleteDocument(String collectionName, String documentId) {
    return LocalstoreHelpers.deleteDocument(collectionName, documentId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String collectionName) {
    return LocalstoreHelpers.getAll(collectionName);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    value,
  ) {
    return LocalstoreHelpers.getAllWhere(
      collectionName,
      field,
      operator,
      value,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List> queries,
  ) {
    return LocalstoreHelpers.getAllWheres(collectionName, queries);
  }

  @override
  Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  ) {
    return LocalstoreHelpers.getDocument(collectionName, documentId);
  }

  @override
  Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return LocalstoreHelpers.updateDocument(collectionName, documentId, data);
  }
}
