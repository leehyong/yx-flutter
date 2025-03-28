import 'package:json_annotation/json_annotation.dart';

part 'task_vo.g.dart';

@JsonSerializable()
class TaskVo {
  final int? id;
  final String? name;
  final String? time;
  final String? type;
  final String? department;
  final String? responsible;

  const TaskVo({
    this.id,
    this.name,
    this.time,
    this.type,
    this.department,
    this.responsible,
  });


  factory TaskVo.fromJson(Map<String, dynamic> json) =>
            _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
