// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GraphVo _$GraphVoFromJson(Map<String, dynamic>? json) => GraphVo(
  nodes: (json?['nodes'] as Map<String, dynamic>?)?.map(
    (k, v) => MapEntry(k, Node.fromJson(v as Map<String, dynamic>)),
  ),
  edges:
      (json?['edges'] as List<dynamic>?)
          ?.map((e) => Edge.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$GraphVoToJson(GraphVo instance) => <String, dynamic>{
  'nodes': instance.nodes,
  'edges': instance.edges,
};

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
  label: json['label'] as String,
  responsibleId: json['responsibleId'] as String?,
  responsible: json['responsible'] as String?,
  role: json['role'] as String?,
  type: json['type'] as String?,
  typeName: json['typeName'] as String?,
  children:
      (json['children'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
  'label': instance.label,
  'type': instance.type,
  'typeName': instance.typeName,
  'responsibleId': instance.responsibleId,
  'responsible': instance.responsible,
  'role': instance.role,
  'children': instance.children,
};

Edge _$EdgeFromJson(Map<String, dynamic> json) =>
    Edge(from: json['from'], to: json['to']);

Map<String, dynamic> _$EdgeToJson(Edge instance) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
};
