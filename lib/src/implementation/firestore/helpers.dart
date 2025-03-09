// ignore_for_file: avoid_classes_with_only_static_members, lines_longer_than_80_chars

import 'package:cloud_firestore/cloud_firestore.dart';

import 'errors.dart';
import 'firestore_error.dart';

class FirestoreHelpers {
  /// Adds a document to a collection in Firestore.
  ///
  /// The [collectionName] parameter specifies the name of the collection to add the document to.
  /// The [data] parameter is a map containing the data to be added to the document.
  /// The optional [id] parameter specifies the ID of the document. If not provided, a new ID will be generated.
  ///
  /// Returns a [Future] that completes with the ID of the added document.
  ///
  /// Throws a [FirestoreError] if there is an error adding the document.
  static Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
  }) async {
    try {
      DocumentReference docRef;

      if (id != null) {
        docRef = FirebaseFirestore.instance.collection(collectionName).doc(id);
      } else {
        docRef = await FirebaseFirestore.instance
            .collection(collectionName)
            .add({});
      }

      await docRef.set({...data, 'id': docRef.id});

      return docRef.id;
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
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
    String documentId,
  ) async {
    try {
      final DocumentReference document = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId);

      await document.delete();
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
  }

  /// Retrieves all documents from a Firestore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [FirestoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAll(
    String collectionName,
  ) async {
    try {
      final CollectionReference collectionRef = FirebaseFirestore.instance
          .collection(collectionName);
      final querySnapshot = await collectionRef.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()! as Map<String, dynamic>})
          .toList();
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
  }

  /// Retrieves all documents from a Firestore collection that match a specific condition.
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
  /// Throws a [FirestoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    // ignore: avoid_annotating_with_dynamic
    dynamic value,
  ) async {
    try {
      final CollectionReference collectionRef = FirebaseFirestore.instance
          .collection(collectionName);
      final query = _query(collectionRef, field, operator, value);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()! as Map<String, dynamic>})
          .toList();
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
  }

  /// Retrieves all documents from a Firestore collection based on the specified queries.
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
  /// Throws a [FirestoreError] if there is an error retrieving the documents.
  static Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List<dynamic>> queries,
  ) async {
    try {
      final CollectionReference collectionRef = FirebaseFirestore.instance
          .collection(collectionName);

      Query queryRef = collectionRef;

      for (final q in queries) {
        queryRef = _query(queryRef, q[0] as String, q[1] as String, q[2]);
      }

      final querySnapshot = await queryRef.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()! as Map<String, dynamic>})
          .toList();
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
  }

  /// Retrieves a document from a Firestore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the document from.
  /// The [documentId] parameter specifies the ID of the document to retrieve.
  ///
  /// Returns a [Future] that completes with a [Map] containing the document data. The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws a [FirestoreError] if the document does not exist in the collection.
  static Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      final DocumentReference docRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId);

      final documentSnapshot = await docRef.get();

      if (documentSnapshot.exists) {
        return {
          'id': documentSnapshot.id,
          ...documentSnapshot.data()! as Map<String, dynamic>,
        };
      }

      throw FirestoreError(
        'No document with $documentId in collection $collectionName',
      );
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
    }
  }

  /// Updates a document in a Firestore collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to update the document in.
  /// The [documentId] parameter specifies the ID of the document to update.
  /// The [data] parameter is a map containing the updated data for the document.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws a [FirestoreError] if there is an error updating the document.
  static Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final DocumentReference document = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId);

      await document.update(data);
    } on FirebaseException catch (error) {
      throw FirestoreError(getFirestoreErrorMessage(error));
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

  static Query _query(
    Query initialQuery,
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
        return initialQuery.where(field, isNotEqualTo: value);

      case 'isLessThan':
      case '<':
        return initialQuery.where(field, isLessThan: value);

      case 'isLessThanOrEqualTo':
      case '<=':
        return initialQuery.where(field, isLessThanOrEqualTo: value);

      case 'isGreaterThan':
      case '>':
        return initialQuery.where(field, isGreaterThan: value);

      case 'isGreaterThanOrEqualTo':
      case '>=':
        return initialQuery.where(field, isGreaterThanOrEqualTo: value);

      case 'arrayContains':
        return initialQuery.where(field, arrayContains: value);

      case 'arrayContainsAny':
        return initialQuery.where(
          field,
          arrayContainsAny: value as List<dynamic>,
        );

      case 'whereIn':
        return initialQuery.where(field, whereIn: value as List<dynamic>);

      case 'whereNotIn':
        return initialQuery.where(field, whereNotIn: value as List<dynamic>);

      case 'isNull':
        return initialQuery.where(field, isNull: value as bool?);

      default:
        return initialQuery;
    }
  }
}
