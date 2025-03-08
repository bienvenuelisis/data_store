import 'package:firebase_core/firebase_core.dart';

String getFirestoreErrorMessage(FirebaseException exception) {
  switch (exception.code) {
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
