import 'dart:math';

import '../implementation/localstore/helpers.dart';
import 'data_store_action.dart';

const kDbLogActions = 'db_actions_logs';

class SyncStoreLogger {
  Future<DataStoreAction> add(
    String collectionName,
    Map<String, dynamic> data,
    String id,
  ) async {
    final action = DataStoreAction(
      type: DataStoreActionType.create,
      at: DateTime.now(),
      collectionName: collectionName,
      data: data,
      documentId: id,
      id: _generateId(),
    );

    await LocalstoreHelpers.createDocument(
      kDbLogActions,
      action.toMap(),
      id: action.id,
    );

    return action;
  }

  Future<void> delete(String collectionName, String documentId) async {
    final action = DataStoreAction(
      type: DataStoreActionType.delete,
      at: DateTime.now(),
      collectionName: collectionName,
      documentId: documentId,
      id: _generateId(),
    );

    await LocalstoreHelpers.createDocument(
      kDbLogActions,
      action.toMap(),
      id: action.id,
    );
  }

  Future<List<DataStoreAction>> getAll([String? collectionName]) async {
    List<Map<String, dynamic>> actions;

    if (collectionName == null) {
      actions = await LocalstoreHelpers.getAll(kDbLogActions);
    } else {
      actions = await LocalstoreHelpers.getAllWhere(
        kDbLogActions,
        'collection_name',
        '==',
        collectionName,
      );
    }

    return DataStoreAction.fromList(actions);
  }

  Future<List<DataStoreAction>> getAllSynced([String? collectionName]) async {
    List<Map<String, dynamic>> actions;

    if (collectionName == null) {
      actions = await LocalstoreHelpers.getAllWhere(
        kDbLogActions,
        'synchronized_at',
        '!=',
        null,
      );
    } else {
      actions = await LocalstoreHelpers.getAllWheres(kDbLogActions, [
        ['collection_name', '==', collectionName],
        ['synchronized_at', '!=', null],
      ]);
    }

    return DataStoreAction.fromList(actions);
  }

  Future<List<DataStoreAction>> getAllUnSynced([String? collectionName]) async {
    List<Map<String, dynamic>> actions;

    if (collectionName == null) {
      actions = await LocalstoreHelpers.getAllWhere(
        kDbLogActions,
        'synchronized_at',
        '==',
        null,
      );
    } else {
      actions = await LocalstoreHelpers.getAllWheres(kDbLogActions, [
        ['collection_name', '==', collectionName],
        ['synchronized_at', '==', null],
      ]);
    }

    return DataStoreAction.fromList(actions);
  }

  Future<void> sync(DataStoreAction action) async {
    await LocalstoreHelpers.updateDocument(kDbLogActions, action.id, {
      'synchronized_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<DataStoreAction> update(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final action = DataStoreAction(
      type: DataStoreActionType.update,
      at: DateTime.now(),
      collectionName: collectionName,
      data: data,
      documentId: documentId,
      id: _generateId(),
    );

    await LocalstoreHelpers.createDocument(
      kDbLogActions,
      action.toMap(),
      id: action.id,
    );

    return action;
  }

  String _generateId() {
    return int.parse(
      '${Random().nextInt(1000000000)}${Random().nextInt(1000000000)}',
    ).toRadixString(35).substring(0, 9);
  }
}
