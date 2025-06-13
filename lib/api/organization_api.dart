import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/cus_user_organization.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';
import 'package:yx/utils/toast.dart';

import 'codes.dart';

// 查询组织树
Future<CusYooOrganizationTree?> queryOrganizationTree() async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/organization/tree",
    );
    final data = handleProtoInstanceVo<CusYooOrganizationTree>(
      resp,
      CusYooOrganizationTree.fromBuffer,
    );
    if (data.$1 == null) {
      return data.$2;
    }
    errToast(data.$1!);
    return null;
  } catch (e) {
    debugPrint('接口 queryOrganizationTree 调用失败：$e');
    return null;
  }
}

Future<List<Organization>> queryAllOrganization() async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/organization/all",
    );
    final data = handleProtoPageInstanceVo<Organization>(
      resp,
      Organization.fromBuffer,
    );
    return data.data ?? <Organization>[];
  } catch (e) {
    debugPrint('接口queryAllOrganization调用失败：$e');
    return <Organization>[];
  }
}

// 查询可加入的组织
Future<List<CusYooOrganizationTree>> queryJoinableOrganizations(
  int page,
  int limit,
) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/organization/joinable/list",
      queryParameters: {"page": page, "limit": limit},
    );
    final data = handleProtoPageInstanceVo<CusYooOrganizationTree>(
      resp,
      CusYooOrganizationTree.fromBuffer,
    );
    return data.data ?? <CusYooOrganizationTree>[];
  } catch (e) {
    debugPrint('接口 queryJoinableOrganizations 调用失败：$e');
    return <CusYooOrganizationTree>[];
  }
}

// 查询可切换的组织
Future<List<SwitchableOrganization>> querySwitchableOrganizations() async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/organization/switchable/list",
    );
    final data = handleProtoPageInstanceVo<SwitchableOrganization>(
      resp,
      SwitchableOrganization.fromBuffer,
    );
    return data.data ?? <SwitchableOrganization>[];
  } catch (e) {
    debugPrint('接口 querySwitchableOrganizations 调用失败：$e');
    return <SwitchableOrganization>[];
  }
}

// 注册组织
Future<bool> registerOrganization(
  Int64 parentOrgId,
  NewOrganization newOrganization,
) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/organization/register",
      queryParameters: {"parent_org_id": parentOrgId},
      data: encodeProtoData(newOrganization),
    );

    return handleProtoCommonInstanceVo(resp, toastSuccess: true)?.isEmpty ??
        false;
  } catch (e) {
    debugPrint('接口 registerOrganization 调用失败：$e');
    return false;
  }
}

// 切换组织
Future<bool> switchOrganization(Int64 orgId, Int64 roleId) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/organization/switch/$orgId/$roleId",
    );
    // 如果切换成功， 那就需要重新设置用户token
    return handleUserLoginTokenToast(
      () => handleTokenResponse(resp, check: true),
    ).isEmpty;
  } catch (e) {
    debugPrint('接口 switchOrganization 调用失败：$e');
    return false;
  }
}

// 切换组织
Future<bool> applyJoinOrganization(Int64 orgId) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/organization/apply/join/$orgId",
    );
    return handleProtoCommonInstanceVo(resp, toastSuccess: true)?.isEmpty ??
        false;
  } catch (e) {
    debugPrint('接口 switchOrganization 调用失败：$e');
    return false;
  }
}
