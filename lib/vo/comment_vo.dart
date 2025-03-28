import 'package:json_annotation/json_annotation.dart';

import 'common_vo.dart';

part 'comment_vo.g.dart';

typedef CommonCommentVo = CommonVo<CommentVo, CommonMapVoData>?;


@JsonSerializable()
class CommentVo {
  final int? count;
  final List<CommentVoData>? data;

  const CommentVo({
    this.count,
    this.data,
  });

  factory CommentVo.fromJson(Map<String, dynamic>? json) =>
      json == null? CommentVo(count: 0, data: []): _$CommentVoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentVoToJson(this);

  CommentVo copyWith({
    int? count,
    List<CommentVoData>? data,
  }) {
    return CommentVo(
      count: count ?? this.count,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class CommentVoData {
  final int? delete;
  final int? edit;
  final String? id;
  final String? dutyId;
  final String? evaluationAuthor;
  final List<int>? createDate;
  final String? evaluationDes;
  final CommentVo? evaluationReply;

  const CommentVoData( {
    this.delete,
    this.edit,
    this.id,
    this.dutyId,
    this.evaluationAuthor,
    this.createDate,
    this.evaluationDes,
    this.evaluationReply
  });

  factory CommentVoData.fromJson(Map<String, dynamic> json) =>
      _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  CommentVoData copyWith({
    int? delete,
    int? edit,
    String? id,
    String? dutyId,
    String? evaluationAuthor,
    List<int>? createDate,
    String? evaluationDes,
  }) {
    return CommentVoData(
      delete: delete ?? this.delete,
      edit: edit ?? this.edit,
      id: id ?? this.id,
      dutyId: dutyId ?? this.dutyId,
      evaluationAuthor: evaluationAuthor ?? this.evaluationAuthor,
      createDate: createDate ?? this.createDate,
      evaluationDes: evaluationDes ?? this.evaluationDes,
    );
  }
}
