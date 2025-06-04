import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';
import 'package:yx/utils/toast.dart';

import '../types.dart';
import 'codes.dart';

Future<ProtoPageVo<UserTaskHistory>> queryWorkTasks(
  TaskListCategory cat,
  int page,
  int limit,
  Int64 parentId,
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

Future<WorkTask?> queryWorkTaskInfoById(
  Int64 id, {
  bool isParent = false,
}) async {
  try {
    final p = isParent ? 'parent' : 'detail';
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/$p/$id",
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

Future<String?> bindWorkTaskHeader(Int64 taskId, List<Int64> headerIds) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      "$apiContextPath/work-task/bind-header/$taskId",
      data: encodeProtoData(
        UpdateYooWorkTask(common: CommonYooWorkTask(headerIds: headerIds)),
      ),
    );
    return handleProtoCommonInstanceVo(resp, toastSuccess: true);
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
}

Future<bool> handleActionWorkTaskHeader(
  Int64 taskId,
  UserTaskAction action,
) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      "$apiContextPath/work-task/action/$taskId",
      queryParameters: {"action": action.index},
    );
    final err = handleProtoCommonInstanceVo(resp, toastSuccess: true);
    return err == null || err.isEmpty;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<String?> deleteWorkTask(Int64 id) async {
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

Future<List<User>> taskRelSelectedUsers(Int64 id) async {
  try {
    if (id < Int64(1)) {
      return <User>[];
    }
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/select-user/$id",
    );
    final data = handleProtoPageInstanceVo<User>(resp, User.fromBuffer);
    return data.data ?? <User>[];
  } catch (e) {
    debugPrint(e.toString());
    return <User>[];
  }
}

Future<List<CusYooWorkTaskTreeRelateOrganization>>
taskTreeRelateOrganization() async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/tree/task",
    );
    final data =
        handleProtoPageInstanceVo<CusYooWorkTaskTreeRelateOrganization>(
          resp,
          CusYooWorkTaskTreeRelateOrganization.fromBuffer,
        );
    return data.data ?? <CusYooWorkTaskTreeRelateOrganization>[];
  } catch (e) {
    debugPrint(e.toString());
    return <CusYooWorkTaskTreeRelateOrganization>[];
  }
}

Future<List<CusYooOrganizationTreeRelateTask>>
organizationTreeRelateTask() async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/tree/organization",
    );
    final data = handleProtoPageInstanceVo<CusYooOrganizationTreeRelateTask>(
      resp,
      CusYooOrganizationTreeRelateTask.fromBuffer,
    );
    return data.data ?? <CusYooOrganizationTreeRelateTask>[];
  } catch (e) {
    debugPrint(e.toString());
    return <CusYooOrganizationTreeRelateTask>[];
  }
}

Future<CusYooWorkTaskGraphViewData?> taskGraphViewData(Int64 organizationId) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/graph-view/task",
      queryParameters: {"org_id": organizationId},
    );
    final data = handleProtoInstanceVo<CusYooWorkTaskGraphViewData>(
      resp,
      CusYooWorkTaskGraphViewData.fromBuffer,
    );
    if (data.$1 == null) {
      return data.$2;
    }
    errToast(data.$1!);
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<CusYooOrganizationGraphViewData?> organizationGraphViewData(Int64 taskId) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-task/graph-view/organization",
      queryParameters: {"task_id": taskId},
    );
    final data = handleProtoInstanceVo<CusYooOrganizationGraphViewData>(
      resp,
      CusYooOrganizationGraphViewData.fromBuffer,
    );
    if (data.$1 == null) {
      return data.$2;
    }
    errToast(data.$1!);
    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
