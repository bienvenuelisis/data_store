import 'package:firebase_core/firebase_core.dart';

/// Base custom Firestore exception class for handling errors with user-friendly
/// messages
abstract class FirestoreException implements Exception {
  const FirestoreException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when user doesn't have permission to access a document
class FirestorePermissionDeniedException extends FirestoreException {
  const FirestorePermissionDeniedException([
    super.message = 'You do not have permission to access this document.',
  ]) : super(code: 'permission-denied');
}

/// Exception thrown when the requested document does not exist
class FirestoreNotFoundException extends FirestoreException {
  const FirestoreNotFoundException([
    super.message = 'The requested document does not exist.',
  ]) : super(code: 'not-found');
}

/// Exception thrown when the operation was cancelled
class FirestoreCancelledException extends FirestoreException {
  const FirestoreCancelledException([
    super.message = 'The operation was cancelled.',
  ]) : super(code: 'cancelled');
}

/// Exception thrown when an internal error occurred in Firestore
class FirestoreInternalException extends FirestoreException {
  const FirestoreInternalException([
    super.message = 'An internal error occurred in Firestore.',
  ]) : super(code: 'internal');
}

/// Exception thrown when invalid arguments were provided to the operation
class FirestoreInvalidArgumentException extends FirestoreException {
  const FirestoreInvalidArgumentException([
    super.message =
        'Invalid arguments were provided to the Firestore operation.',
  ]) : super(code: 'invalid-argument');
}

/// Exception thrown when the operation timed out
class FirestoreDeadlineExceededException extends FirestoreException {
  const FirestoreDeadlineExceededException([
    super.message = 'The operation timed out.',
  ]) : super(code: 'deadline-exceeded');
}

/// Exception thrown when Firestore is unavailable
class FirestoreUnavailableException extends FirestoreException {
  const FirestoreUnavailableException([
    super.message = 'Firestore is unavailable at this time.',
  ]) : super(code: 'unavailable');
}

/// Exception thrown when the precondition for the operation failed
class FirestoreFailedPreconditionException extends FirestoreException {
  const FirestoreFailedPreconditionException([
    super.message = 'The precondition for the operation failed.',
  ]) : super(code: 'failed-precondition');
}

/// Exception thrown when the operation was aborted
class FirestoreAbortedException extends FirestoreException {
  const FirestoreAbortedException([
    super.message = 'The operation was aborted.',
  ]) : super(code: 'aborted');
}

/// Exception thrown when the document or field path is too deep
class FirestoreOutOfRangeException extends FirestoreException {
  const FirestoreOutOfRangeException([
    super.message = 'The document or field path is too deep.',
  ]) : super(code: 'out-of-range');
}

/// Exception thrown for unknown Firestore errors
class FirestoreUnknownException extends FirestoreException {
  const FirestoreUnknownException([
    super.message = 'An unknown Firestore error occurred.',
    String? code,
  ]) : super(code: code);
}

/// Utility class for handling Firestore errors
class FirestoreErrorHandler {
  FirestoreErrorHandler._();

  /// Creates a specific FirestoreException based on the error code
  static FirestoreException createFirestoreException(
    String? errorCode, [
    String? customMessage,
  ]) {
    switch (errorCode) {
      case 'permission-denied':
        return customMessage != null
            ? FirestorePermissionDeniedException(customMessage)
            : const FirestorePermissionDeniedException();
      case 'not-found':
        return customMessage != null
            ? FirestoreNotFoundException(customMessage)
            : const FirestoreNotFoundException();
      case 'cancelled':
        return customMessage != null
            ? FirestoreCancelledException(customMessage)
            : const FirestoreCancelledException();
      case 'internal':
        return customMessage != null
            ? FirestoreInternalException(customMessage)
            : const FirestoreInternalException();
      case 'invalid-argument':
        return customMessage != null
            ? FirestoreInvalidArgumentException(customMessage)
            : const FirestoreInvalidArgumentException();
      case 'deadline-exceeded':
        return customMessage != null
            ? FirestoreDeadlineExceededException(customMessage)
            : const FirestoreDeadlineExceededException();
      case 'unavailable':
        return customMessage != null
            ? FirestoreUnavailableException(customMessage)
            : const FirestoreUnavailableException();
      case 'failed-precondition':
        return customMessage != null
            ? FirestoreFailedPreconditionException(customMessage)
            : const FirestoreFailedPreconditionException();
      case 'aborted':
        return customMessage != null
            ? FirestoreAbortedException(customMessage)
            : const FirestoreAbortedException();
      case 'out-of-range':
        return customMessage != null
            ? FirestoreOutOfRangeException(customMessage)
            : const FirestoreOutOfRangeException();
      default:
        return FirestoreUnknownException(
          customMessage ?? 'An unknown Firestore error occurred.',
          errorCode,
        );
    }
  }

  /// Gets a descriptive error message based on the Firestore error code
  /// @deprecated Use createFirestoreException instead for better type safety
  static String getFirestoreErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'permission-denied':
        return 'You do not have permission to access this document.';
      case 'not-found':
        return 'The requested document does not exist.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'internal':
        return 'An internal error occurred in Firestore.';
      case 'invalid-argument':
        return 'Invalid arguments were provided to the Firestore operation.';
      case 'deadline-exceeded':
        return 'The operation timed out.';
      case 'unavailable':
        return 'Firestore is unavailable at this time.';
      case 'failed-precondition':
        return 'The precondition for the operation failed.';
      case 'aborted':
        return 'The operation was aborted.';
      case 'out-of-range':
        return 'The document or field path is too deep.';
      default:
        return 'An unknown Firestore error occurred.';
    }
  }

  /// Wraps a Firestore operation in a try-catch block and throws a specific
  /// FirestoreException based on the error type
  static Future<T> handleFirestoreError<T>(
    Future<T> Function() firestoreOperation,
  ) async {
    try {
      return await firestoreOperation();
    } on FirebaseException catch (error) {
      throw createFirestoreException(error.code, error.message);
    } catch (error) {
      throw FirestoreUnknownException('An unexpected error occurred: $error');
    }
  }
}
