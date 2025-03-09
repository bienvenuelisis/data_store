// ignore_for_file: avoid_classes_with_only_static_members, lines_longer_than_80_chars

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstore/localstore.dart';

import 'localstore_error.dart';

class LocalstoreHelpers {
  /// Adds a document to a collection in Localstore.
  ///
  /// The [collectionName] parameter specifies the name of the collection to add the document to.
  /// The [data] parameter is a map containing the data to be added to the document.
  /// The optional [id] parameter specifies the ID of the document. If not provided, a new ID will be generated.
  ///
  /// Returns a [Future] that completes with the ID of the added document.
  ///
  /// Throws a [LocalstoreError] if there is an error adding the document.
  static Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
  }) async {
    try {
      DocumentRef docRef;

      if (id != null) {
        docRef = Localstore.instance.collection(collectionName).doc(id);
      } else {
        docRef = Localstore.instance.collection(collectionName).doc();
      }

      await docRef.set({...data, 'id': docRef.id});

      return docRef.id;
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Deletes a document from a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to delete the document from.
  /// The [documentId] parameter specifies the ID of the document to delete.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws a [LocalstoreError] if there is an error deleting the document.
  static Future<void> deleteDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      final document = Localstore.instance
          .collection(collectionName)
          .doc(documentId);

      await document.delete();
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Retrieves all documents from a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [LocalstoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAll(
    String collectionName,
  ) async {
    try {
      final collectionRef = Localstore.instance.collection(collectionName);
      final documents = await collectionRef.get();

      if (documents == null) {
        throw LocalstoreError(
          'No documents for $collectionName found in Localstore.',
        );
      }

      return documents.values as List<Map<String, dynamic>>;
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Retrieves all documents from a Localstore collection that match a specific condition.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [field] parameter specifies the field to filter the documents by.
  /// The [operator] parameter specifies the comparison operator to use for the filter.
  /// The [value] parameter specifies the value to compare against the field.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [LocalstoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    // ignore: avoid_annotating_with_dynamic
    dynamic value,
  ) async {
    try {
      final collectionRef = Localstore.instance.collection(collectionName);

      final query = _query(collectionRef, field, operator, value);

      final documents = await query.get();

      if (documents == null) {
        throw LocalstoreError(
          'No documents for $collectionName found in Localstore.',
        );
      }

      return documents.values as List<Map<String, dynamic>>;
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Retrieves all documents from a Localstore collection based on the specified queries.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  /// The [queries] parameter is a list of lists, where each inner list represents a query.
  /// The first element of the inner list is the field to filter the documents by,
  /// the second element is the operator to use for the filter,
  /// and the third element is the value to compare against the field.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [LocalstoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List<dynamic>> queries,
  ) async {
    try {
      final collectionRef = Localstore.instance.collection(collectionName);

      var queryRef = collectionRef;

      for (final q in queries) {
        queryRef = _query(queryRef, q[0] as String, q[1] as String, q[2]);
      }

      final documents = await queryRef.get();

      if (documents == null) {
        throw LocalstoreError(
          'No documents for $collectionName found in Localstore.',
        );
      }

      return documents.values as List<Map<String, dynamic>>;
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Retrieves a document from a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the document from.
  /// The [documentId] parameter specifies the ID of the document to retrieve.
  ///
  /// Returns a [Future] that completes with a [Map] containing the document data. The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [LocalstoreError] if the document does not exist in the collection.
  static Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      final docRef = Localstore.instance
          .collection(collectionName)
          .doc(documentId);

      final document = await docRef.get();

      return document!;
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Updates a document in a Localstore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to update the document in.
  /// The [documentId] parameter specifies the ID of the document to update.
  /// The [data] parameter is a map containing the updated data for the document.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws a [LocalstoreError] if there is an error updating the document.
  static Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final oldData = await getDocument(collectionName, documentId);

      final document = Localstore.instance
          .collection(collectionName)
          .doc(documentId);

      await document.set({...oldData, ...data});
    } on Exception catch (error) {
      throw LocalstoreError(error.toString());
    }
  }

  /// Returns a [Query] object based on the given [initialQuery], [field], [operator], and [value].
  ///
  /// The [initialQuery] is the initial query object to which the where clause is added.
  /// The [field] is the name of the field to be used in the where clause.
  /// The [operator] is the comparison operator to be used in the where clause.
  /// The [value] is the value to be compared against in the where clause.
  ///
  /// The function returns a [Query] object with the added where clause based on the given parameters.
  /// If the [operator] is not one of the supported comparison operators, the function returns the [initialQuery] unchanged.
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
  /// Throws:
  /// - None.
  ///
  /// Returns:
  /// - A [Query] object with the added where clause based on the given parameters.
  /// - If the [operator] is not one of the supported comparison operators, the function returns the [initialQuery] unchanged.

  static CollectionRef _query(
    CollectionRef initialQuery,
    String field,
    String operator,
    // ignore: avoid_annotating_with_dynamic
    dynamic value,
  ) {
    switch (operator) {
      case 'isEqualTo':
      case '=':
      case '==':
      case '===':
        return initialQuery.where(field, isEqualTo: value);

      case 'isNotEqualTo':
      case '!=':
      case '!==':
        return initialQuery..addCondition(field, operator, value);

      case 'isLessThan':
      case '<':
        return initialQuery..addCondition(field, operator, value);

      case 'isLessThanOrEqualTo':
      case '<=':
        return initialQuery..addCondition(field, operator, value);

      case 'isGreaterThan':
      case '>':
        return initialQuery..addCondition(field, operator, value);

      case 'isGreaterThanOrEqualTo':
      case '>=':
        return initialQuery..addCondition(field, operator, value);

      case 'arrayContains':
        return initialQuery..addCondition(field, operator, value);

      case 'arrayContainsAny':
        return initialQuery..addCondition(field, operator, value);

      case 'whereIn':
        return initialQuery..addCondition(field, operator, value);

      case 'whereNotIn':
        return initialQuery..addCondition(field, operator, value);

      case 'isNull':
        return initialQuery..addCondition(field, operator, value);

      default:
        return initialQuery;
    }
  }
}
