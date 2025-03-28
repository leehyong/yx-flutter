// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskVo _$TaskFromJson(Map<String, dynamic> json) => TaskVo(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  time: json['time'] as String?,
  type: json['type'] as String?,
  department: json['department'] as String?,
  responsible: json['responsible'] as String?,
);

Map<String, dynamic> _$TaskToJson(TaskVo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'time': instance.time,
  'type': instance.type,
  'department': instance.department,
  'responsible': instance.responsible,
};
