import 'package:json_annotation/json_annotation.dart';

import 'common_vo.dart';

part 'room_vo.g.dart';
typedef CommonRoomVo = CommonVo<List<RoomVo>, CommonListVoData>?;

@JsonSerializable()
class RoomVo{
  final String? departmentId;
  final String? dutyDepartmentName;
  final String? centerName;

  const RoomVo({this.departmentId, this.dutyDepartmentName, this.centerName});

  factory RoomVo.fromJson(Map<String, dynamic> json) => _$RoomVoFromJson(json);

  get departmentName => dutyDepartmentName;

  Map<String, dynamic> toJson() => _$RoomVoToJson(this);

}

List<RoomVo>? deserializeRoomVoFromList(List<dynamic>? obj) =>
    obj?.map((e) => RoomVo.fromJson(e as Map<String, dynamic>)).toList();

