import 'package:json_annotation/json_annotation.dart';

part 'user_login_vo.g.dart';

@JsonSerializable()
class UserLoginVo {
  final int? code;
  final String? message;
  final String? data;
  final String? date;

  const UserLoginVo({
    this.code,
    this.message,
    this.data,
    this.date,
  });

  factory UserLoginVo.fromJson(Map<String, dynamic> json) =>
      _$UserLoginVoFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginVoToJson(this);
}
