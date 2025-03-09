abstract class IDataStore {
  const IDataStore();

  /// Adds a document to a collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to add the document to.
  /// The [data] parameter is a map containing the data to be added to the document.
  /// The optional [id] parameter specifies the ID of the document. If not provided, a new ID will be generated.
  ///
  /// Returns a [Future] that completes with the ID of the added document.
  ///
  /// Throws an [Exception] if there is an error adding the document.
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data, {
    String? id,
  });

  /// Deletes a document from a collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to delete the document from.
  /// The [documentId] parameter specifies the ID of the document to delete.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws an [Exception] if there is an error deleting the document.
  Future<void> deleteDocument(String collectionName, String documentId);

  /// Retrieves all documents from a collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the documents from.
  ///
  /// Returns a [Future] that completes with a [List] of [Map]s, where each map represents a document.
  /// The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws an [Exception] if there is an error retrieving the documents.
  Future<List<Map<String, dynamic>>> getAll(String collectionName);

  /// Retrieves all documents from a collection that match a specific condition.
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
  /// Throws an [Exception] if there is an error retrieving the documents.
  Future<List<Map<String, dynamic>>> getAllWhere(
    String collectionName,
    String field,
    String operator,
    dynamic value,
  );

  /// Retrieves all documents from a collection based on the specified queries.
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
  /// Throws an [Exception] if there is an error retrieving the documents.
  Future<List<Map<String, dynamic>>> getAllWheres(
    String collectionName,
    List<List<dynamic>> queries,
  );

  /// Retrieves a document from a collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to retrieve the document from.
  /// The [documentId] parameter specifies the ID of the document to retrieve.
  ///
  /// Returns a [Future] that completes with a [Map] containing the document data. The map has the following keys:
  /// - 'id': The ID of the document.
  /// - All other keys: The data fields of the document.
  ///
  /// Throws an [Exception] if the document does not exist in the collection.
  Future<Map<String, dynamic>> getDocument(
    String collectionName,
    String documentId,
  );

  /// Updates a document in a collection.
  ///
  /// The [collectionName] parameter specifies the name of the collection to update the document in.
  /// The [documentId] parameter specifies the ID of the document to update.
  /// The [data] parameter is a map containing the updated data for the document.
  ///
  /// Returns a [Future] that completes with void.
  ///
  /// Throws an [Exception] if there is an error updating the document.
  Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  );
}
