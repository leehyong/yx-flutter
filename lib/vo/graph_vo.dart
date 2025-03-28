import 'package:json_annotation/json_annotation.dart';

import 'common_vo.dart';

part 'graph_vo.g.dart';

typedef CommonGraphVo = CommonVo<GraphVo, CommonMapVoData>?;

@JsonSerializable()
class GraphVo {
  final Map<String, Node>? nodes;
  final List<Edge>? edges;

  const GraphVo({this.nodes, this.edges});

  factory GraphVo.fromJson(Map<String, dynamic>? json) =>
      _$GraphVoFromJson(json);

  Object? toJson() => _$GraphVoToJson(this);
}

@JsonSerializable()
class Node {
  final String label;
  final String? responsibleId;
  final String? responsible;
  final String? role;
  final String? type;
  final String? typeName;
  final List<String> children;

  const Node({
    required this.label,
    required this.children,
    this.responsibleId,
    this.responsible,
    this.role,
    this.type,
    this.typeName,
  });

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);
}

@JsonSerializable()
class Edge {
  final String from;
  final String to;

  const Edge({required this.from, required this.to});

  factory Edge.fromJson(Map<String, dynamic> json) => _$EdgeFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeToJson(this);
}
