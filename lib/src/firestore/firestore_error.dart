// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart';

import 'errors.dart';

class FirestoreError implements Exception {
  FirestoreError(this.message);

  final String message;

  @override
  String toString() => 'FirestoreError: $message';
}

/// Handles a Firestore error by catching a [FirebaseException] and throwing a [FirestoreError] with the corresponding error message.
///
/// The [operation] parameter is the asynchronous operation that may throw a [FirebaseException].
///
/// Returns a [Future] that completes with the result of the [operation] if it succeeds.
///
/// Throws a [FirestoreError] if a [FirebaseException] is caught during the execution of the [operation].
///
/// If any other exception is caught, it is rethrown.
Future<T> handleFirestoreError<T>(Future<T> operation) async {
  try {
    return await operation;
  } on FirebaseException catch (error) {
    final errorMessage = getFirestoreErrorMessage(error);
    throw FirestoreError(errorMessage);
  } catch (error) {
    // Handle other non-Firestore exceptions (optional)
    rethrow;
  }
}
