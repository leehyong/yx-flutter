import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import 'codes.dart';

Future<List<CusYooHeaderTree>?> queryWorkHeaders([Int64? taskId]) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-header/all",
      queryParameters: {"task_id": taskId ?? ''},
    );
    return handleProtoPageInstanceVo<CusYooHeaderTree>(
      resp,
      CusYooHeaderTree.fromBuffer,
    ).data;
  } catch (e) {
    debugPrint('接口 queryWorkHeaders 调用失败：$e');
    return null;
  }
}

Future<Int64> newWorkHeader(
  Int64 taskId,
  Int64 parent,
  NewWorkHeader data,
) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/work-header/$parent",
      data: encodeProtoData(data),
      queryParameters: {"task_id": taskId},
    );
    return handleProtoCommonInstanceVoForMsgIncludeInt64(
          resp,
          toastSuccess: true,
        ) ??
        Int64.ZERO;
  } catch (e) {
    debugPrint('接口 newWorkHeader 调用失败：$e');
    return Int64.ZERO;
  }
}

Future<String?> updateWorkHeader(Int64 id, UpdateWorkHeader data) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      "$apiContextPath/work-header/$id",
      data: encodeProtoData(data),
    );
    return handleProtoCommonInstanceVo(resp);
  } catch (e) {
    debugPrint('接口 updateWorkHeader 调用失败：$e');
    return e.toString();
  }
}

Future<String?> deleteWorkHeader(Int64 taskId, Int64 id) async {
  try {
    final resp = await HttpDioService.instance.dio.delete<String>(
      "$apiContextPath/work-header/$id",
      queryParameters: {"task_id": taskId},
    );
    return handleProtoCommonInstanceVo(resp);
  } catch (e) {
    debugPrint('接口 deleteWorkHeader 调用失败：$e');
    return e.toString();
  }
}
