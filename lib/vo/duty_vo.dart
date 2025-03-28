import 'package:yx/vo/room_vo.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common_vo.dart';

part 'duty_vo.g.dart';

typedef CommonDutyVo = CommonVo<List<DutyVo>, CommonListVoData>?;
@JsonSerializable()
class DutyVo {
  final String? acctMonth;
  final List<RoomVo>? collaborativeDepartment;
  final String? collaborativeDepartmentId;
  final int? collaborativeIfPostpone;
  final String? controlMethod;
  final String? createDate;
  final String? createStaff;
  final String? dutyCompletionDes;
  final String? dutyDes;
  final String? dutyEndDate;
  final int? dutyFlg;
  final int? dutyLevel;
  final String? dutyName;
  final List<DutyParticipant>? dutyParticipant;
  final int? dutyProgress;
  final int? dutyQuantificationMethod;
  final String? dutyType;
  final String? dutyTypeSubTitle;
  final String? dutyUrgency;
  final List<EvaluationDepartment>? evaluationDepartment;
  final String? evaluationDepartmentId;
  final List<EvaluationLeader>? evaluationLeader;
  final String? evaluationLeaderId;
  final String? id;
  final String? parentDutyId;
  final List<RoomVo>? responsibleDepartment;
  final String? responsibleDepartmentId;
  final int? responsibleIfPostpone;
  final List<ResponsiblePerson>? responsiblePerson;
  final String? responsiblePersonId;
  final String? dutyImportance;
  const DutyVo({
    this.acctMonth,
    this.collaborativeDepartment,
    this.collaborativeDepartmentId,
    this.collaborativeIfPostpone,
    this.controlMethod,
    this.createDate,
    this.createStaff,
    this.dutyCompletionDes,
    this.dutyDes,
    this.dutyEndDate,
    this.dutyFlg,
    this.dutyLevel,
    this.dutyName,
    this.dutyParticipant,
    this.dutyProgress,
    this.dutyQuantificationMethod,
    this.dutyType,
    this.dutyTypeSubTitle,
    this.dutyUrgency,
    this.evaluationDepartment,
    this.evaluationDepartmentId,
    this.evaluationLeader,
    this.evaluationLeaderId,
    this.id,
    this.parentDutyId,
    this.responsibleDepartment,
    this.responsibleDepartmentId,
    this.responsibleIfPostpone,
    this.responsiblePerson,
    this.responsiblePersonId,
    this.dutyImportance,
  });

  factory DutyVo.fromJson(Map<String, dynamic> json) =>
      _$DutyFromJson(json);

  Map<String, dynamic> toJson() => _$DutyToJson(this);
}

@JsonSerializable()
class CollaborativeDepartment {
  final String? createDate;
  final String? departmentId;
  final String? dutyDepartmentId;
  final String? dutyDepartmentName;
  final String? dutyId;
  final int? dutyProgress;
  final String? id;

  const CollaborativeDepartment({
    this.createDate,
    this.departmentId,
    this.dutyDepartmentId,
    this.dutyDepartmentName,
    this.dutyId,
    this.dutyProgress,
    this.id,
  });

  factory CollaborativeDepartment.fromJson(Map<String, dynamic> json) =>
      _$CollaborativeDepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborativeDepartmentToJson(this);
}

@JsonSerializable()
class DutyParticipant {
  final String? createDate;
  final String? dutyCompletion;
  final String? dutyId;
  final String? dutyResponsibleId;
  final String? id;
  final String? responsible;
  final String? responsibleId;
  final int? responsibleType;

  const DutyParticipant({
    this.createDate,
    this.dutyCompletion,
    this.dutyId,
    this.dutyResponsibleId,
    this.id,
    this.responsible,
    this.responsibleId,
    this.responsibleType,
  });

  factory DutyParticipant.fromJson(Map<String, dynamic> json) =>
      _$DutyParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$DutyParticipantToJson(this);
}

@JsonSerializable()
class EvaluationDepartment {
  final String? createDate;
  final String? department;
  final String? departmentId;
  final String? dutyDepartmentEvaluationId;
  final String? dutyId;
  final String? evaluationDes;
  final String? evaluationPerson;
  final String? evaluationPersonId;
  final String? id;

  const EvaluationDepartment({
    this.createDate,
    this.department,
    this.departmentId,
    this.dutyDepartmentEvaluationId,
    this.dutyId,
    this.evaluationDes,
    this.evaluationPerson,
    this.evaluationPersonId,
    this.id,
  });

  factory EvaluationDepartment.fromJson(Map<String, dynamic> json) =>
      _$EvaluationDepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationDepartmentToJson(this);
}

@JsonSerializable()
class EvaluationLeader {
  final String? createDate;
  final String? dutyId;
  final String? dutyLeaderEvaluationId;
  final String? evaluationDes;
  final String? id;
  final String? leader;
  final String? leaderId;

  const EvaluationLeader({
    this.createDate,
    this.dutyId,
    this.dutyLeaderEvaluationId,
    this.evaluationDes,
    this.id,
    this.leader,
    this.leaderId,
  });

  factory EvaluationLeader.fromJson(Map<String, dynamic> json) =>
      _$EvaluationLeaderFromJson(json);

  Map<String, dynamic> toJson() => _$EvaluationLeaderToJson(this);
}

@JsonSerializable()
class ResponsibleDepartment {
  final String? createDate;
  final String? departmentId;
  final String? dutyDepartmentId;
  final String? dutyDepartmentName;
  final String? dutyId;
  final int? dutyProgress;
  final String? id;

  const ResponsibleDepartment({
    this.createDate,
    this.departmentId,
    this.dutyDepartmentId,
    this.dutyDepartmentName,
    this.dutyId,
    this.dutyProgress,
    this.id,
  });

  factory ResponsibleDepartment.fromJson(Map<String, dynamic> json) =>
      _$ResponsibleDepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsibleDepartmentToJson(this);
}

@JsonSerializable()
class ResponsiblePerson {
  final String? createDate;
  final String? dutyCompletion;
  final String? dutyId;
  final String? dutyResponsibleId;
  final String? id;
  final String? responsible;
  final String? responsibleId;
  final int? responsibleType;

  const ResponsiblePerson({
    this.createDate,
    this.dutyCompletion,
    this.dutyId,
    this.dutyResponsibleId,
    this.id,
    this.responsible,
    this.responsibleId,
    this.responsibleType,
  });

  factory ResponsiblePerson.fromJson(Map<String, dynamic> json) =>
      _$ResponsiblePersonFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsiblePersonToJson(this);
}

List<DutyVo>? deserializeDutyFromList(List<dynamic>? obj) =>
    obj?.map((e) => DutyVo.fromJson(e as Map<String, dynamic>)).toList();