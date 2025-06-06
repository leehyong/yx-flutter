import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/cus_content.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import 'codes.dart';

Future<ProtoPageVo<CusYooWorkContent>?> queryWorkTaskContents(
  Int64 taskId,
  int page,
  int limit,
) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/work-content/$taskId",
      queryParameters: {"page": page, "limit": limit},
    );
    return handleProtoPageInstanceVo<CusYooWorkContent>(
      resp,
      CusYooWorkContent.fromBuffer,
    );
  } catch (e) {
    debugPrint('接口 queryWorkTaskContents 调用失败：$e');
    return ProtoPageVo.fail(e.toString());
  }
}

Future<String?> newWorkTaskContent(Int64 taskId, NewCusYooWorkContentReq data) async {
  try {
    final resp = await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/work-content/$taskId",
      data: encodeProtoData(data),
    );
    return handleProtoCommonInstanceVo(resp, toastSuccess: true);
  } catch (e) {
    debugPrint('接口 queryWorkTaskContents 调用失败：$e');
    return e.toString();
  }
}

Future<String?> updateWorkTaskContent(
  Int64 id,
  UpdateCusYooWorkContentReq data,
) async {
  try {
    final resp = await HttpDioService.instance.dio.put<String>(
      "$apiContextPath/work-content/$id",
      data: encodeProtoData(data),
    );
    return handleProtoCommonInstanceVo(resp, toastSuccess: true);
  } catch (e) {
    debugPrint('接口 updateWorkTaskContent 调用失败：$e');
    return e.toString();
  }
}

Future<String?> deleteWorkTaskContent(Int64 id) async {
  try {
    final resp = await HttpDioService.instance.dio.delete<String>(
      "$apiContextPath/work-content/$id",
    );
    return handleProtoCommonInstanceVo(resp);
  } catch (e) {
    debugPrint('接口 deleteWorkTaskContent 调用失败：$e');
    return e.toString();
  }
}
