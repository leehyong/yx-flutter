import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import '../types.dart';
import 'codes.dart';

Future<ProtoPageVo<UserTaskHistory>> queryWorkTasks(
  TaskListCategory cat,
  int page,
  int limit,
  int parentId,
) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/all",
      queryParameters: {
        "page": page,
        "limit": limit,
        "cat": cat.index,
        "parent_id": parentId,
      },
    );
    return handleProtoPageInstanceVo<UserTaskHistory>(
      resp,
      UserTaskHistory.fromBuffer,
    );
  } catch (e) {
    debugPrint(e.toString());
    return ProtoPageVo.fail(e.toString());
  }
}

Future<WorkTask?> queryWorkTaskInfoById(Int64 id) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/$id",
    );
    return handleProtoInstanceVo<WorkTask>(resp, WorkTask.fromBuffer).$2;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<Int64> newWorkTask(NewYooWorkTask data) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/work-task",
      data: encodeProtoData(data),
    );
    return handleProtoCommonInstanceVoForMsgIncludeInt64(
          resp,
          toastSuccess: data.task.status != SystemTaskStatus.published.index,
        ) ??
        Int64.ZERO;
  } catch (e) {
    debugPrint(e.toString());
    return Int64.ZERO;
  }
}

Future<String?> updateWorkTask(Int64 taskId, UpdateYooWorkTask data) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      "$apiContextPath/work-task/$taskId",
      data: encodeProtoData(data),
    );
    return handleProtoCommonInstanceVo(
      resp,
      toastSuccess: data.task.status != SystemTaskStatus.published.index,
    );
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
}

Future<String?> deleteWorkTask(int id) async {
  try {
    final resp = await HttpDioService.instance.dio.delete<String>(
      "$apiContextPath/work-task/$id",
    );
    return handleProtoCommonInstanceVo(resp, toastSuccess: true);
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
}
