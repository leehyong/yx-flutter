import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import 'codes.dart';

Future<ProtoPageVo<CusYooTaskComment>?> queryAllComments(
  Int64 id,
  Int64 taskId,
  int page,
  int limit,
) async {
  final query = {"id": id, "task_id": taskId, "limit": limit, "page": page};
  try {
    // 通过任务id查询评论
    var resp = await HttpDioService.instance.dio.get<String>(
      '$apiContextPath/task-comment/all',
      queryParameters: query,
    );
    return handleProtoPageInstanceVo<CusYooTaskComment>(
      resp,
      CusYooTaskComment.fromBuffer,
    );
  } catch (e) {
    debugPrint('接口 queryAllComments 调用失败：$e');
    return ProtoPageVo.fail(e.toString());
  }
}

// 新增评论或者回复
Future<bool> addTaskComment(
  Int64 taskId,
  NewTaskComment data, {
  Int64? replyId,
}) async {
  try {
    var resp = await HttpDioService.instance.dio.post<String>(
      '$apiContextPath/task-comment/$taskId',
      data: encodeProtoData(data),
      queryParameters: {"parent_id": replyId ?? Int64.ZERO},
    );
    final res = handleProtoCommonInstanceVo(resp);
    return res == null || res.isEmpty;
  } catch (e) {
    debugPrint('接口 addTaskComment 调用失败：$e');
    return false;
  }
}

Future<bool> deleteTaskComment(Int64 id) async {
  try {
    var resp = await HttpDioService.instance.dio.delete<String>(
      '$apiContextPath/task-comment/$id',
    );
    final res = handleProtoCommonInstanceVo(resp);
    return res == null || res.isEmpty;
  } catch (e) {
    debugPrint('接口 deleteTaskComment 调用失败：$e');
    return false;
  }
}

Future<bool> updateTaskComment(
  Int64 id,
  UpdateTaskComment comment,
  int mask,
) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      '$apiContextPath/task-comment/$id',
      queryParameters: {"mask": mask},
      data: encodeProtoData(comment),
    );
    final res = handleProtoCommonInstanceVo(resp);
    return res == null || res.isEmpty;
  } catch (e) {
    debugPrint('接口 updateTaskComment 调用失败：$e');
    return false;
  }
}
