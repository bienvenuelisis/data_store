// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum DataStoreActionType {
  create,
  delete,
  update,
}

class DataStoreAction {
  DataStoreAction({
    required this.at,
    required this.collectionName,
    required this.documentId,
    required this.id,
    required this.type,
    this.data,
    this.synchronizedAt,
  });

  factory DataStoreAction.fromJson(String source) => DataStoreAction.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  factory DataStoreAction.fromMap(Map<String, dynamic> map) {
    return DataStoreAction(
      id: map['id'] as String,
      collectionName: (map['collection_name'] ?? '') as String,
      at: DateTime.fromMillisecondsSinceEpoch((map['at'] ?? 0) as int),
      data: (map['data'] != null ? jsonDecode(map['data'] as String) : null)
          as Map<String, dynamic>?,
      documentId: map['document_id'] as String,
      synchronizedAt: map['synchronized_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['synchronized_at'] ?? 0) as int,
            )
          : null,
      type: DataStoreActionType.values.byName(map['type'] as String),
    );
  }

  final DateTime at;
  final String collectionName;
  final Map<String, dynamic>? data;
  final String documentId;
  final String id;
  final DateTime? synchronizedAt;
  final DataStoreActionType type;

  bool get synchronized => synchronizedAt != null;

  static List<DataStoreAction> fromList(List<Map<String, dynamic>> actions) {
    return actions
        .map(
          DataStoreAction.fromMap,
        )
        .toList();
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'collection_name': collectionName,
      'at': at.millisecondsSinceEpoch,
      'data': jsonEncode(data ?? <String, dynamic>{}),
      'document_id': documentId,
      'synchronized_at': synchronizedAt?.millisecondsSinceEpoch,
      'type': type.name,
    };
  }
}
