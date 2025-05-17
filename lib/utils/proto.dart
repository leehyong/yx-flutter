import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:yt_dart/common.pb.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/encrypt.dart';

import '../api/codes.dart';

CommonVo _decodeCommonVoData(String data) =>
    CommonVo.fromBuffer(base64Decode(data));

CommonPageDataVo _decodeCommonPageVoData(String data) =>
    CommonPageDataVo.fromBuffer(base64Decode(data));

(String?, CommonVo?) decodeCommonVoDataFromResponse(Response<String> response) {
  final h =
      response.headers["content-type"] ?? response.headers["Content-type"];
  if (isOkResponse(response)) {
    assert(h!.first == protobufResponse);
    final commonVoData = _decodeCommonVoData(response.data!);
    return (null, commonVoData);
  } else {
    assert(h!.first == textPlainResponse);
    final rd = response.data?.trim();
    final error =
    (rd?.isNotEmpty ?? false) ? rd : (response.statusMessage ?? '接口请求失败');
    debugPrint(error);
    return (response.data ?? response.statusMessage ?? '接口请求失败', null);
  }
}

(String?, CommonPageDataVo?) decodeCommonPageVoDataFromResponse(
  Response<String> response,
) {
  final h =
      response.headers["content-type"] ?? response.headers["Content-type"];
  if (isOkResponse(response)) {
    assert(h!.first == protobufResponse);
    final commonVoData = _decodeCommonPageVoData(response.data!);
    return (null, commonVoData);
  } else {
    assert(h!.first == textPlainResponse);
    final rd = response.data?.trim();
    final error =
        (rd?.isNotEmpty ?? false) ? rd : (response.statusMessage ?? '接口请求失败');
    debugPrint(error);
    return (error, null);
  }
}

String encodeProtoData<M extends $pb.GeneratedMessage>(M msg) =>
    base64Encode(msg.writeToBuffer());

String encryptProtoData<M extends $pb.GeneratedMessage>(M msg) =>
    encodeProtoData(
      EncryptedData(data: encryptWith04Prefix(msg.writeToBuffer())),
    );
