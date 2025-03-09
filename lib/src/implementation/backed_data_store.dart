// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:data_store_impl/src/implementation/firebase_data_store.dart';
import 'package:data_store_impl/src/implementation/local_data_store.dart';
import 'package:data_store_impl/src/interface/i_data_store.dart';
import 'package:data_store_impl/src/sync/data_store_action.dart';
import 'package:flutter/material.dart';

import '../implementation/firestore/index.dart';
import '../implementation/localstore/index.dart';

// ignore: avoid_classes_with_only__members
class BackedDataStore extends IDataStore {
  /// The online store to use.
  final IDataStore _onlineStore;

  /// The offline store to use.
  final IDataStore _offlineStore;

  BackedDataStore({
    IDataStore onlineStore = const FirebaseDataStore(),
    IDataStore offlineStore = const LocalDataStore(),
  }) : _onlineStore = onlineStore,
       _offlineStore = offlineStore;

  @override
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
    bool forceSynchronization = false,
  }) async {
    String? finalId;

    if (id != null) {
      finalId = id;
    }

    if (forceSynchronization) {
      finalId = await _onlineStore.createDocument(
        collectionName,
        data,
        id: finalId,
      );

      await _offlineStore.createDocument(collectionName, data, id: finalId);

      return finalId;
    }

    finalId = await _offlineStore.createDocument(
      collectionName,
      data,
      id: finalId,
    );

    try {
      await _onlineStore.createDocument(collectionName, data, id: finalId);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await SyncStoreLogger().add(collectionName, data, finalId);
    }

    return finalId;
  }

  @override
  Future<void> deleteDocument(
    String collectionName,
    String documentId, {
    bool forceSynchronization = false,
  }) async {
    if (forceSynchronization) {
      await _onlineStore.deleteDocument(collectionName, documentId);

      await _offlineStore.deleteDocument(collectionName, documentId);

      return;
    }

    await _offlineStore.deleteDocument(collectionName, documentId);

    try {
      await _onlineStore.deleteDocument(collectionName, documentId);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await SyncStoreLogger().delete(collectionName, documentId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(
    String collectionName, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return _onlineStore.getAll(collectionName);
    }

    if (preferOnlineStore) {
      try {
        return _onlineStore.getAll(collectionName);
      } catch (e) {
        return _offlineStore.getAll(collectionName);
      }
    }

    return _offlineStore.getAll(collectionName);
  }

  /// Retrieves all documents from a Firestore collection or a Localstore collection that match a specific condition.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [field] parameter specifies the field to filter the documents by.
  /// The [operator] parameter specifies the comparison operator to use for the filter.
  /// The [value] parameter specifies the value to compare against the field.
  ///
  /// Supported comparison operators:
  /// - "isEqualTo": Equal to operator.
  /// - "=": Equal to operator.
  /// - "==": Equal to operator.
  /// - "===": Equal to operator.
  /// - "isNotEqualTo": Not equal to operator.
  /// - "!=": Not equal to operator.
  /// - "!==": Not equal to operator.
  /// - "isLessThan": Less than operator.
  /// - "<": Less than operator.
  /// - "isLessThanOrEqualTo": Less than or equal to operator.
  /// - "<=": Less than or equal to operator.
  /// - "isGreaterThan": Greater than operator.
  /// - ">": Greater than operator.
  /// - "isGreaterThanOrEqualTo": Greater than or equal to operator.
  /// - ">=": Greater than or equal to operator.
  /// - "arrayContains": Array contains operator.
  /// - "arrayContainsAny": Array contains any operator.
  /// - "whereIn": Where in operator.
  /// - "whereNotIn": Where not in operator.
  /// - "isNull": Is null operator.
  ///
  /// The [preferOnlineStore] parameter determines whether to prefer retrieving the documents from Firestore.
  /// If set to `true`, the function will first try to retrieve the documents from Firestore and if an error occurs,
  /// it will fall back to retrieving them from Localstore.
  ///
  /// The [getOnlyFromOnlineStore] parameter determines whether to only retrieve the documents from Firestore.
  /// If set to `true`, the function will only retrieve the documents from Firestore and will not fall back to Localstore.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [FirestoreError] or [LocalstoreError] if there is an error retrieving the documents.
  @override
  Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    // ignore: avoid_annotating_with_dynamic
    dynamic value, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return _onlineStore.getAllWhere(collectionName, field, operator, value);
    }

    if (preferOnlineStore) {
      try {
        return _onlineStore.getAllWhere(collectionName, field, operator, value);
      } catch (e) {
        return _offlineStore.getAllWhere(
          collectionName,
          field,
          operator,
          value,
        );
      }
    }

    return _offlineStore.getAllWhere(collectionName, field, operator, value);
  }

  /// Retrieves all documents from a Firestore collection or a Localstore collection that match multiple conditions.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [queries] parameter is a list of lists, where each inner list represents a query.
  /// Supported comparison operators:
  /// - "isEqualTo": Equal to operator.
  /// - "=": Equal to operator.
  /// - "==": Equal to operator.
  /// - "===": Equal to operator.
  /// - "isNotEqualTo": Not equal to operator.
  /// - "!=": Not equal to operator.
  /// - "!==": Not equal to operator.
  /// - "isLessThan": Less than operator.
  /// - "<": Less than operator.
  /// - "isLessThanOrEqualTo": Less than or equal to operator.
  /// - "<=": Less than or equal to operator.
  /// - "isGreaterThan": Greater than operator.
  /// - ">": Greater than operator.
  /// - "isGreaterThanOrEqualTo": Greater than or equal to operator.
  /// - ">=": Greater than or equal to operator.
  /// - "arrayContains": Array contains operator.
  /// - "arrayContainsAny": Array contains any operator.
  /// - "whereIn": Where in operator.
  /// - "whereNotIn": Where not in operator.
  /// - "isNull": Is null operator.
  ///
  /// The first element of the inner list is the field to filter the documents by,
  /// the second element is the operator to use for the filter,
  /// and the third element is the value to compare against the field.
  ///
  /// The [preferOnlineStore] parameter determines whether to prefer retrieving the documents from Firestore.
  /// If set to `true`, the function will first try to retrieve the documents from Firestore and if an error occurs,
  /// it will fall back to retrieving them from Localstore.
  ///
  /// The [getOnlyFromOnlineStore] parameter determines whether to only retrieve the documents from Firestore.
  /// If set to `true`, the function will only retrieve the documents from Firestore and will not fall back to Localstore.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [FirestoreError] or [LocalstoreError] if there is an error retrieving the documents.
  @override
  Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List<dynamic>> queries, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return _onlineStore.getAllWheres(collectionName, queries);
    }

    if (preferOnlineStore) {
      try {
        return _onlineStore.getAllWheres(collectionName, queries);
      } catch (e) {
        return _offlineStore.getAllWheres(collectionName, queries);
      }
    }

    return _offlineStore.getAllWheres(collectionName, queries);
  }

  /// Retrieves a document from a Firestore collection or a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the document from.
  /// The [documentId] parameter specifies the ID of the document to retrieve.
  ///
  /// The [preferOnlineStore] parameter determines whether to prefer retrieving the document from Firestore.
  /// If set to `true`, the function will first try to retrieve the document from Firestore and if an error occurs,
  /// it will fall back to retrieving it from Localstore.
  ///
  /// The [getOnlyFromOnlineStore] parameter determines whether to only retrieve the document from Firestore.
  /// If set to `true`, the function will only retrieve the document from Firestore and will not fall back to Localstore.
  ///
  /// Returns a [Future] that completes with a [Map] containing the document data. The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [FirestoreError] or [LocalstoreError] if there is an error retrieving the document.
  @override
  Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return _onlineStore.getDocument(collectionName, documentId);
    }

    if (preferOnlineStore) {
      try {
        return _onlineStore.getDocument(collectionName, documentId);
      } catch (e) {
        return _offlineStore.getDocument(collectionName, documentId);
      }
    }

    return _offlineStore.getDocument(collectionName, documentId);
  }

  FutureOr<bool> synchronize(DataStoreAction action) async {
    try {
      switch (action.type) {
        case DataStoreActionType.create:
          await _onlineStore.createDocument(
            action.collectionName,
            action.data!,
            id: action.documentId,
          );

        case DataStoreActionType.update:
          await _onlineStore.updateDocument(
            action.collectionName,
            action.documentId,
            action.data!,
          );

        case DataStoreActionType.delete:
          await _onlineStore.deleteDocument(
            action.collectionName,
            action.documentId,
          );
      }
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }

    try {
      await SyncStoreLogger().sync(action);

      return true;
    } catch (e) {
      debugPrint(e.toString());

      // revert(action);

      return false;
    }
  }

  Future<List<DataStoreAction>> toSync<T>(
    String collectionName,
    T Function(Map<String, dynamic>) toModel,
  ) async {
    try {
      return SyncStoreLogger().getAllSynced(collectionName);
    } catch (e) {
      return [];
    }
  }

  /// Updates a document in the specified Datastore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to update the document in.
  /// The [documentId] parameter specifies the ID of the document to update.
  /// The [data] parameter is a map containing the updated data for the document.
  /// The [forceSynchronization] parameter (optional, defaults to false) specifies whether to force synchronization if an error occurs during the update.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws a [FirestoreError] or [LocalstoreError] if there is an error updating the document.

  @override
  Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data, {
    bool forceSynchronization = false,
  }) async {
    if (forceSynchronization) {
      await _onlineStore.updateDocument(collectionName, documentId, data);

      await _offlineStore.updateDocument(collectionName, documentId, data);

      return;
    }

    await _offlineStore.updateDocument(collectionName, documentId, data);

    try {
      await _onlineStore.updateDocument(collectionName, documentId, data);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await SyncStoreLogger().update(collectionName, documentId, data);
    }
  }
}
