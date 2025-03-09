class LocalstoreError implements Exception {
  LocalstoreError(this.message);

  final String message;

  @override
  String toString() => 'LocalstoreError: $message';
}

/// Handles a Localstore error by catching a [Exception] and throwing a
/// [LocalstoreError] with the corresponding error message.
///
/// The [operation] parameter is the asynchronous operation that may throw a
/// [Exception].
///
/// Returns a [Future] that completes with the result of the [operation] if it
/// succeeds.
///
/// Throws a [LocalstoreError] if a [Exception] is caught during the
/// execution of the [operation].
///
/// If any other exception is caught, it is rethrow.
Future<T> handleLocalstoreError<T>(Future<T> operation) async {
  try {
    return await operation;
  } on Exception catch (error) {
    throw LocalstoreError(error.toString());
  } catch (error) {
    // Handle other non-Localstore exceptions (optional)
    rethrow;
  }
}
