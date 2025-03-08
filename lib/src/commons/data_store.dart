// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';

import '../firestore/index.dart';
import '../localstore/index.dart';
import 'data_store_action.dart';

// ignore: avoid_classes_with_only_static_members
class DataStoreHelpers {
  /// Creates a new document in the specified Datastore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to create the document in.
  /// The [data] parameter specifies the data to be stored in the document.
  /// The [forceSynchronization] parameter (optional, defaults to false) specifies whether to force synchronization if an error occurs during the creation of the document.
  ///
  /// Returns a [Future] that completes with the ID of the newly created document.
  ///
  /// Throws an [Exception] if an error occurs during the creation of the document.
  static Future<String> createDocument(
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
      finalId = await FirestoreHelpers.createDocument(
        collectionName,
        data,
        id: finalId,
      );

      await LocalstoreHelpers.createDocument(collectionName, data, id: finalId);

      return finalId;
    }

    finalId = await LocalstoreHelpers.createDocument(
      collectionName,
      data,
      id: finalId,
    );

    try {
      await FirestoreHelpers.createDocument(collectionName, data, id: finalId);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await LocalStoreLogger().add(collectionName, data, finalId);
    }

    return finalId;
  }

  /// Deletes a document from a Firestore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to delete the document from.
  /// The [documentId] parameter specifies the ID of the document to delete.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws a [FirestoreError] if there is an error deleting the document.
  static Future<void> deleteDocument(
    String collectionName,
    String documentId, {
    bool forceSynchronization = false,
  }) async {
    if (forceSynchronization) {
      await FirestoreHelpers.deleteDocument(collectionName, documentId);

      await LocalstoreHelpers.deleteDocument(collectionName, documentId);

      return;
    }

    await LocalstoreHelpers.deleteDocument(collectionName, documentId);

    try {
      await FirestoreHelpers.deleteDocument(collectionName, documentId);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await LocalStoreLogger().delete(collectionName, documentId);
    }
  }

  // Retrieves all documents from a Firestore collection or a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
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
  /// Throws a [FirestoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAll(
    String collectionName, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return FirestoreHelpers.getAll(collectionName);
    }

    if (preferOnlineStore) {
      try {
        return FirestoreHelpers.getAll(collectionName);
      } catch (e) {
        return LocalstoreHelpers.getAll(collectionName);
      }
    }

    return LocalstoreHelpers.getAll(collectionName);
  }

  /// Retrieves all documents from a Firestore collection or a Localstore collection that match a specific condition.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [field] parameter specifies the field to filter the documents by.
  /// The [operator] parameter specifies the comparison operator to use for the filter.
  /// The [value] parameter specifies the value to compare against the field.
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
  static Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    // ignore: avoid_annotating_with_dynamic
    dynamic value, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return FirestoreHelpers.getAllWhere(
        collectionName,
        field,
        operator,
        value,
      );
    }

    if (preferOnlineStore) {
      try {
        return FirestoreHelpers.getAllWhere(
          collectionName,
          field,
          operator,
          value,
        );
      } catch (e) {
        return LocalstoreHelpers.getAllWhere(
          collectionName,
          field,
          operator,
          value,
        );
      }
    }

    return LocalstoreHelpers.getAllWhere(
      collectionName,
      field,
      operator,
      value,
    );
  }

  /// Retrieves all documents from a Firestore collection or a Localstore collection that match multiple conditions.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [queries] parameter is a list of lists, where each inner list represents a query.
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
  static Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List<dynamic>> queries, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return FirestoreHelpers.getAllWheres(collectionName, queries);
    }

    if (preferOnlineStore) {
      try {
        return FirestoreHelpers.getAllWheres(collectionName, queries);
      } catch (e) {
        return LocalstoreHelpers.getAllWheres(collectionName, queries);
      }
    }

    return LocalstoreHelpers.getAllWheres(collectionName, queries);
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
  static Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId, {
    bool preferOnlineStore = false,
    bool getOnlyFromOnlineStore = false,
  }) async {
    if (getOnlyFromOnlineStore) {
      return FirestoreHelpers.getDocument(collectionName, documentId);
    }

    if (preferOnlineStore) {
      try {
        return FirestoreHelpers.getDocument(collectionName, documentId);
      } catch (e) {
        return LocalstoreHelpers.getDocument(collectionName, documentId);
      }
    }

    return LocalstoreHelpers.getDocument(collectionName, documentId);
  }

  static FutureOr<bool> synchronize(DataStoreAction action) async {
    try {
      switch (action.type) {
        case DataStoreActionType.create:
          await FirestoreHelpers.createDocument(
            action.collectionName,
            action.data!,
            id: action.documentId,
          );

        case DataStoreActionType.update:
          await FirestoreHelpers.updateDocument(
            action.collectionName,
            action.documentId,
            action.data!,
          );

        case DataStoreActionType.delete:
          await FirestoreHelpers.deleteDocument(
            action.collectionName,
            action.documentId,
          );
      }
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }

    try {
      await LocalStoreLogger().sync(action);

      return true;
    } catch (e) {
      debugPrint(e.toString());

      // revert(action);

      return false;
    }
  }

  static Future<List<T>> toSync<T>(
    String collectionName,
    T Function(Map<String, dynamic>) toModel,
  ) async {
    try {
      final dataToSync = await LocalStoreLogger().getAllSynced(collectionName);

      return dataToSync.map((e) => toModel(e.data!)).toList();
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

  static Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data, {
    bool forceSynchronization = false,
  }) async {
    if (forceSynchronization) {
      await FirestoreHelpers.updateDocument(collectionName, documentId, data);

      await LocalstoreHelpers.updateDocument(collectionName, documentId, data);

      return;
    }

    await LocalstoreHelpers.updateDocument(collectionName, documentId, data);

    try {
      await FirestoreHelpers.updateDocument(collectionName, documentId, data);
    } on Exception catch (e) {
      debugPrint(e.toString());

      await LocalStoreLogger().update(collectionName, documentId, data);
    }
  }
}
