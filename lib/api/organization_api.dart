import 'package:flutter/foundation.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/toast.dart';

import 'codes.dart';

// 查询这种树
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
