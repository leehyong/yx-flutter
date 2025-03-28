// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLoginVo _$UserLoginVoFromJson(Map<String, dynamic> json) => UserLoginVo(
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] as String?,
  date: json['date'] as String?,
);

Map<String, dynamic> _$UserLoginVoToJson(UserLoginVo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
      'date': instance.date,
    };
