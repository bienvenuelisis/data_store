# Data Store

A package that provides local and online data storage implementations, and synchronization options.

## Features

- Local data storage using `Localstore`
- Online data storage using `Firestore` (via `BackedDataStore`)
- A common `DataStore` interface for consistent API usage.
- Synchronization options between local and online data stores (if applicable).
- Error handling for data store operations.

## Getting Started

To start using the `data_store_impl` package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  data_store_impl: ^0.0.3
  # Ensure you also have cloud_firestore and localstore if using them directly or for setup
  # cloud_firestore: ^4.0.0 # Example version
  # localstore: ^1.3.5 # Example version
```

Then, run `flutter pub get` to install the package.

## Usage

### Creating a Document

To create a new document in a collection:

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  final data = {'name': 'John Doe', 'age': 30};
  final documentId = await DataStoreHelpers.createDocument('users', data);
  print('Document created with ID: $documentId');
}
```

### Updating a Document

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  final data = {'name': 'Jane Doe', 'age': 25};
  await DataStoreHelpers.updateDocument('users', 'documentId', data);
  print('Document updated');
}
```

To update an existing document:

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  final data = {'name': 'Jane Doe', 'age': 25};
  await DataStoreHelpers.updateDocument('users', 'documentId', data);
  print('Document updated');
}
```

### Deleting a Document

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  await DataStoreHelpers.deleteDocument('users', 'documentId');
  print('Document deleted');
}
```

To delete a document:

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  await DataStoreHelpers.deleteDocument('users', 'documentId');
  print('Document deleted');
}
```

## Error Handling

The package provides error handling for both Localstore and Firestore operations. For example, to handle errors when creating a document:

```dart
import 'package:data_store_impl/data_store_impl.dart';

void main() async {
  try {
    final data = {'name': 'John Doe', 'age': 30};
    final documentId = await DataStoreHelpers.createDocument('users', data);
    print('Document created with ID: $documentId');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Additional Information

For more information, visit the [GitHub repository](https://github.com/bienvenuelisis/.git).

To contribute to the package, please open an issue or submit a pull request on the issue tracker.

## License

This package is licensed under the MIT License. See the [LICENSE](https://github.com/bienvenuelisis//blob/main/LICENSE) file for more information.
