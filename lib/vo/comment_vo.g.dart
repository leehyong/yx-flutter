// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentVo _$CommentVoFromJson(Map<String, dynamic> json) => CommentVo(
  count: (json['count'] as num?)?.toInt(),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => CommentVoData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CommentVoToJson(CommentVo instance) => <String, dynamic>{
  'count': instance.count,
  'data': instance.data,
};

CommentVoData _$DataFromJson(Map<String, dynamic> json) => CommentVoData(
  delete: (json['delete'] as num?)?.toInt(),
  edit: (json['edit'] as num?)?.toInt(),
  id: json['id'] as String?,
  dutyId: json['dutyId'] as String?,
  evaluationAuthor: json['evaluationAuthor'] as String?,
  createDate:
      (json['createDate'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  evaluationDes: json['evaluationDes'] as String?,
  evaluationReply: _$EvaluationReplyFromJson(
    json['evaluationReply'] as Map<String, dynamic>?,
  ),
);

Map<String, dynamic> _$DataToJson(CommentVoData instance) => <String, dynamic>{
  'delete': instance.delete,
  'edit': instance.edit,
  'id': instance.id,
  'dutyId': instance.dutyId,
  'evaluationAuthor': instance.evaluationAuthor,
  'createDate': instance.createDate,
  'evaluationDes': instance.evaluationDes,
  'evaluationReply': _$EvaluationReplyToJson(instance.evaluationReply),
};

CommentVo? _$EvaluationReplyFromJson(Map<String, dynamic>? json) =>
    json == null
        ? null
        : CommentVo(
          count: (json['count'] as num?)?.toInt() ?? 0,
          data:
              (json['data'] as List<dynamic>?)
                  ?.map(
                    (e) => CommentVoData.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
        );

Map<String, dynamic>? _$EvaluationReplyToJson(CommentVo? instance) =>
    instance == null
        ? null
        : <String, dynamic>{'count': instance.count, 'data': instance.data};
