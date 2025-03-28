// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DutyVo _$DutyFromJson(Map<String, dynamic> json) => DutyVo(
  acctMonth: json['acctMonth'] as String?,
  collaborativeDepartment:
      (json['collaborativeDepartment'] as List<dynamic>?)
          ?.map((e) => RoomVo.fromJson(e as Map<String, dynamic>))
          .toList(),
  collaborativeDepartmentId: json['collaborativeDepartmentId'] as String?,
  collaborativeIfPostpone: (json['collaborativeIfPostpone'] as num?)?.toInt(),
  controlMethod: json['controlMethod'] as String?,
  createDate: json['createDate'] as String?,
  createStaff: json['createStaff'] as String?,
  dutyCompletionDes: json['dutyCompletionDes'] as String?,
  dutyDes: json['dutyDes'] as String?,
  dutyEndDate: json['dutyEndDate'] as String?,
  dutyFlg: (json['dutyFlg'] as num?)?.toInt(),
  dutyLevel: (json['dutyLevel'] as num?)?.toInt(),
  dutyName: json['dutyName'] as String?,
  dutyParticipant:
      (json['dutyParticipant'] as List<dynamic>?)
          ?.map((e) => DutyParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
  dutyProgress: (json['dutyProgress'] as num?)?.toInt(),
  dutyQuantificationMethod: (json['dutyQuantificationMethod'] as num?)?.toInt(),
  dutyType: json['dutyType'] as String?,
  dutyTypeSubTitle: json['dutyTypeSubTitle'] as String?,
  dutyUrgency: json['dutyUrgency'] as String?,
  evaluationDepartment:
      (json['evaluationDepartment'] as List<dynamic>?)
          ?.map((e) => EvaluationDepartment.fromJson(e as Map<String, dynamic>))
          .toList(),
  evaluationDepartmentId: json['evaluationDepartmentId'] as String?,
  evaluationLeader:
      (json['evaluationLeader'] as List<dynamic>?)
          ?.map((e) => EvaluationLeader.fromJson(e as Map<String, dynamic>))
          .toList(),
  evaluationLeaderId: json['evaluationLeaderId'] as String?,
  id: json['id'] as String?,
  parentDutyId: json['parentDutyId'] as String?,
  responsibleDepartment:
      (json['responsibleDepartment'] as List<dynamic>?)
          ?.map((e) => RoomVo.fromJson(e as Map<String, dynamic>))
          .toList(),
  responsibleDepartmentId: json['responsibleDepartmentId'] as String?,
  responsibleIfPostpone: (json['responsibleIfPostpone'] as num?)?.toInt(),
  responsiblePerson:
      (json['responsiblePerson'] as List<dynamic>?)
          ?.map((e) => ResponsiblePerson.fromJson(e as Map<String, dynamic>))
          .toList(),
  responsiblePersonId: json['responsiblePersonId'] as String?,
    dutyImportance: json['dutyImportance'] as String?,
);

Map<String, dynamic> _$DutyToJson(DutyVo instance) => <String, dynamic>{
  'acctMonth': instance.acctMonth,
  'collaborativeDepartment': instance.collaborativeDepartment,
  'collaborativeDepartmentId': instance.collaborativeDepartmentId,
  'collaborativeIfPostpone': instance.collaborativeIfPostpone,
  'controlMethod': instance.controlMethod,
  'createDate': instance.createDate,
  'createStaff': instance.createStaff,
  'dutyCompletionDes': instance.dutyCompletionDes,
  'dutyDes': instance.dutyDes,
  'dutyEndDate': instance.dutyEndDate,
  'dutyFlg': instance.dutyFlg,
  'dutyLevel': instance.dutyLevel,
  'dutyName': instance.dutyName,
  'dutyParticipant': instance.dutyParticipant,
  'dutyProgress': instance.dutyProgress,
  'dutyQuantificationMethod': instance.dutyQuantificationMethod,
  'dutyType': instance.dutyType,
  'dutyTypeSubTitle': instance.dutyTypeSubTitle,
  'dutyUrgency': instance.dutyUrgency,
  'evaluationDepartment': instance.evaluationDepartment,
  'evaluationDepartmentId': instance.evaluationDepartmentId,
  'evaluationLeader': instance.evaluationLeader,
  'evaluationLeaderId': instance.evaluationLeaderId,
  'id': instance.id,
  'parentDutyId': instance.parentDutyId,
  'responsibleDepartment': instance.responsibleDepartment,
  'responsibleDepartmentId': instance.responsibleDepartmentId,
  'responsibleIfPostpone': instance.responsibleIfPostpone,
  'responsiblePerson': instance.responsiblePerson,
  'responsiblePersonId': instance.responsiblePersonId,
  'dutyImportance':instance.dutyImportance,
};

CollaborativeDepartment _$CollaborativeDepartmentFromJson(
  Map<String, dynamic> json,
) => CollaborativeDepartment(
  createDate: json['createDate'] as String?,
  departmentId: json['departmentId'] as String?,
  dutyDepartmentId: json['dutyDepartmentId'] as String?,
  dutyDepartmentName: json['dutyDepartmentName'] as String?,
  dutyId: json['dutyId'] as String?,
  dutyProgress: (json['dutyProgress'] as num?)?.toInt(),
  id: json['id'] as String?,
);

Map<String, dynamic> _$CollaborativeDepartmentToJson(
  CollaborativeDepartment instance,
) => <String, dynamic>{
  'createDate': instance.createDate,
  'departmentId': instance.departmentId,
  'dutyDepartmentId': instance.dutyDepartmentId,
  'dutyDepartmentName': instance.dutyDepartmentName,
  'dutyId': instance.dutyId,
  'dutyProgress': instance.dutyProgress,
  'id': instance.id,
};

DutyParticipant _$DutyParticipantFromJson(Map<String, dynamic> json) =>
    DutyParticipant(
      createDate: json['createDate'] as String?,
      dutyCompletion: json['dutyCompletion'] as String?,
      dutyId: json['dutyId'] as String?,
      dutyResponsibleId: json['dutyResponsibleId'] as String?,
      id: json['id'] as String?,
      responsible: json['responsible'] as String?,
      responsibleId: json['responsibleId'] as String?,
      responsibleType: (json['responsibleType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DutyParticipantToJson(DutyParticipant instance) =>
    <String, dynamic>{
      'createDate': instance.createDate,
      'dutyCompletion': instance.dutyCompletion,
      'dutyId': instance.dutyId,
      'dutyResponsibleId': instance.dutyResponsibleId,
      'id': instance.id,
      'responsible': instance.responsible,
      'responsibleId': instance.responsibleId,
      'responsibleType': instance.responsibleType,
    };

EvaluationDepartment _$EvaluationDepartmentFromJson(
  Map<String, dynamic> json,
) => EvaluationDepartment(
  createDate: json['createDate'] as String?,
  department: json['department'] as String?,
  departmentId: json['departmentId'] as String?,
  dutyDepartmentEvaluationId: json['dutyDepartmentEvaluationId'] as String?,
  dutyId: json['dutyId'] as String?,
  evaluationDes: json['evaluationDes'] as String?,
  evaluationPerson: json['evaluationPerson'] as String?,
  evaluationPersonId: json['evaluationPersonId'] as String?,
  id: json['id'] as String?,
);

Map<String, dynamic> _$EvaluationDepartmentToJson(
  EvaluationDepartment instance,
) => <String, dynamic>{
  'createDate': instance.createDate,
  'department': instance.department,
  'departmentId': instance.departmentId,
  'dutyDepartmentEvaluationId': instance.dutyDepartmentEvaluationId,
  'dutyId': instance.dutyId,
  'evaluationDes': instance.evaluationDes,
  'evaluationPerson': instance.evaluationPerson,
  'evaluationPersonId': instance.evaluationPersonId,
  'id': instance.id,
};

EvaluationLeader _$EvaluationLeaderFromJson(Map<String, dynamic> json) =>
    EvaluationLeader(
      createDate: json['createDate'] as String?,
      dutyId: json['dutyId'] as String?,
      dutyLeaderEvaluationId: json['dutyLeaderEvaluationId'] as String?,
      evaluationDes: json['evaluationDes'] as String?,
      id: json['id'] as String?,
      leader: json['leader'] as String?,
      leaderId: json['leaderId'] as String?,
    );

Map<String, dynamic> _$EvaluationLeaderToJson(EvaluationLeader instance) =>
    <String, dynamic>{
      'createDate': instance.createDate,
      'dutyId': instance.dutyId,
      'dutyLeaderEvaluationId': instance.dutyLeaderEvaluationId,
      'evaluationDes': instance.evaluationDes,
      'id': instance.id,
      'leader': instance.leader,
      'leaderId': instance.leaderId,
    };

ResponsibleDepartment _$ResponsibleDepartmentFromJson(
  Map<String, dynamic> json,
) => ResponsibleDepartment(
  createDate: json['createDate'] as String?,
  departmentId: json['departmentId'] as String?,
  dutyDepartmentId: json['dutyDepartmentId'] as String?,
  dutyDepartmentName: json['dutyDepartmentName'] as String?,
  dutyId: json['dutyId'] as String?,
  dutyProgress: (json['dutyProgress'] as num?)?.toInt(),
  id: json['id'] as String?,
);

Map<String, dynamic> _$ResponsibleDepartmentToJson(
  ResponsibleDepartment instance,
) => <String, dynamic>{
  'createDate': instance.createDate,
  'departmentId': instance.departmentId,
  'dutyDepartmentId': instance.dutyDepartmentId,
  'dutyDepartmentName': instance.dutyDepartmentName,
  'dutyId': instance.dutyId,
  'dutyProgress': instance.dutyProgress,
  'id': instance.id,
};

ResponsiblePerson _$ResponsiblePersonFromJson(Map<String, dynamic> json) =>
    ResponsiblePerson(
      createDate: json['createDate'] as String?,
      dutyCompletion: json['dutyCompletion'] as String?,
      dutyId: json['dutyId'] as String?,
      dutyResponsibleId: json['dutyResponsibleId'] as String?,
      id: json['id'] as String?,
      responsible: json['responsible'] as String?,
      responsibleId: json['responsibleId'] as String?,
      responsibleType: (json['responsibleType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResponsiblePersonToJson(ResponsiblePerson instance) =>
    <String, dynamic>{
      'createDate': instance.createDate,
      'dutyCompletion': instance.dutyCompletion,
      'dutyId': instance.dutyId,
      'dutyResponsibleId': instance.dutyResponsibleId,
      'id': instance.id,
      'responsible': instance.responsible,
      'responsibleId': instance.responsibleId,
      'responsibleType': instance.responsibleType,
    };
