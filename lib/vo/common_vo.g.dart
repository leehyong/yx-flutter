// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonVo<T, De> _$CommonVoFromJson<T, De>(
  Map<String, dynamic> json,
  { FromJsonFn<T, De>? fromJsonT}
) => CommonVo<T, De>(
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  date: json['date'] as String?,
  data: fromJsonT == null ? null : _$nullableGenericFromJson(json['data'], fromJsonT),
);

Object _$CommonVoToJson<Ser>(CommonVo instance,  ToJsonFn toJson,) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'date': instance.date,
  'data': _$nullableGenericToJson(instance.data, toJson),
};

T? _$nullableGenericFromJson<T, De>(
  Object? input,
  FromJsonFn<T, De> fromJson,
) => (input == null || fromJson == null) ? null : fromJson(input as De);

Object? _$nullableGenericToJson<T, Ser>(
  T? input,
    ToJsonFn toJson,
) => (input == null || toJson == null) ? null : toJson(input as Ser);
