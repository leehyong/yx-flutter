import 'package:json_annotation/json_annotation.dart';

import 'common_vo.dart';

part 'user_info_vo.g.dart';
typedef CommonUserVo = CommonVo<List<UserInfoVo>, CommonListVoData>?;

@JsonSerializable()
class UserInfoVo {
  final String? userId;
  final String? userName;
  final String? userNickname;
  final dynamic userAge;
  final String? userGender;
  final String? userPhone;
  final String? userEmail;
  final int? userStatus;
  final String? userTheme;
  final String? userOrganiId;
  final dynamic userAvatarId;
  final dynamic userLastLoginDate;
  final String? userCreateDate;
  final String? userCreateUserId;
  final String? userUpdateDate;
  final dynamic stateDate;
  final String? userUpdateUserId;
  final bool? userDisplay;
  final String? userJobTitle;
  final bool? leader;
  final dynamic userRoles;
  final dynamic userOrgani;
  final dynamic userAvatar;
  final String? userRealName;
  final String? userIdNumber;
  final bool? userPasswordExpired;
  final dynamic userPasswordExpiredDate;
  final int? userLoginCount;
  final bool? userCustomPassword;
  final int? sort;
  final dynamic tenantUid;
  final dynamic tenant;
  final dynamic rank1Organi;
  final dynamic parentOrgani;
  final bool? exit;
  final bool? admin;

  const UserInfoVo({
    this.userId,
    this.userName,
    this.userNickname,
    this.userAge,
    this.userGender,
    this.userPhone,
    this.userEmail,
    this.userStatus,
    this.userTheme,
    this.userOrganiId,
    this.userAvatarId,
    this.userLastLoginDate,
    this.userCreateDate,
    this.userCreateUserId,
    this.userUpdateDate,
    this.stateDate,
    this.userUpdateUserId,
    this.userDisplay,
    this.userJobTitle,
    this.leader,
    this.userRoles,
    this.userOrgani,
    this.userAvatar,
    this.userRealName,
    this.userIdNumber,
    this.userPasswordExpired,
    this.userPasswordExpiredDate,
    this.userLoginCount,
    this.userCustomPassword,
    this.sort,
    this.tenantUid,
    this.tenant,
    this.rank1Organi,
    this.parentOrgani,
    this.exit,
    this.admin,
  });

  factory UserInfoVo.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

List<UserInfoVo>? deserializeUserFromList(List<dynamic>? obj) =>
    obj?.map((e) => UserInfoVo.fromJson(e as Map<String, dynamic>)).toList();