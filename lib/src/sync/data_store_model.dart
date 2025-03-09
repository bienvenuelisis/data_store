import 'dart:async';

import '../implementation/firestore/index.dart';
import '../implementation/localstore/index.dart';
import 'data_store.dart';

abstract class DatastoreModel<T> {
  String get collectionName;

  String? get id;

  Future<void> deleteLocal() async {
    if (id == null) {
      throw LocalstoreError('Document ID is null');
    }

    await LocalstoreHelpers.deleteDocument(collectionName, id!);
  }

  Future<void> deleteOnline() async {
    if (id == null) {
      throw FirestoreError('Document ID is null');
    }

    await FirestoreHelpers.deleteDocument(collectionName, id!);
  }

  T fromMap(Map<String, dynamic> data);

  Future<String> saveLocal() async {
    return LocalstoreHelpers.createDocument(collectionName, toMap(), id: id);
  }

  Future<String> saveOnline() async {
    return FirestoreHelpers.createDocument(collectionName, toMap(), id: id);
  }

  Map<String, dynamic> toMap();

  Future<void> updateLocal() async {
    if (id == null) {
      throw LocalstoreError('Document ID is null');
    }

    await LocalstoreHelpers.updateDocument(collectionName, id!, toMap());
  }

  Future<void> updateOnline() async {
    if (id == null) {
      throw FirestoreError('Document ID is null');
    }

    await FirestoreHelpers.updateDocument(collectionName, id!, toMap());
  }
}

abstract class DatastoreModelImpl<T> extends DatastoreModel<T> {
  DatastoreModelImpl([this._id]) {
    if (_id != null) {
      unawaited(refresh());
    }
  }

  Map<String, dynamic>? _data;
  String? _id;

  @override
  String? get id => _id;

  Map<String, dynamic>? get data => _data;

  Future<String> create() async {
    _id = await DataStoreHelpers.createDocument(collectionName, toMap());

    _data = await DataStoreHelpers.getDocument(collectionName, _id!);

    return _id!;
  }

  Future<bool> delete() async {
    await DataStoreHelpers.deleteDocument(collectionName, _id!);

    return true;
  }

  Future<T> refresh() async {
    _data = await DataStoreHelpers.getDocument(collectionName, _id!);

    return fromMap(_data!);
  }

  Future<String> update() async {
    await DataStoreHelpers.updateDocument(collectionName, _id!, toMap());

    _data = await DataStoreHelpers.getDocument(collectionName, _id!);

    return _id!;
  }
}
