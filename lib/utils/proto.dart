import 'dart:convert';

import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:yt_dart/common.pb.dart';
import 'package:yx/utils/encrypt.dart';

import '../api/codes.dart';

CommonVo _decodeCommonVoData(String data) =>
    CommonVo.fromBuffer(base64Decode(data));

CommonPageDataVo _decodeCommonPageVoData(String data) =>
    CommonPageDataVo.fromBuffer(base64Decode(data));

(String?, CommonVo?) decodeCommonVoDataFromResponse(Response<String> response) {
  final h =
      response.headers?["content-type"] ?? response.headers?["Content-type"];
  if (response.isOk) {
    assert(h == protobufResponse);
    final commonVoData = _decodeCommonVoData(response.body!);
    return (null, commonVoData);
  } else {
    assert(h == textPlainResponse);
    return (response.body ?? response.statusText ?? '接口请求失败', null);
  }
}

(String?, CommonPageDataVo?) decodeCommonPageVoDataFromResponse(
  Response<String> response,
) {
  final h =
      response.headers?["content-type"] ?? response.headers?["Content-type"];
  if (response.isOk) {
    assert(h == protobufResponse);
    final commonVoData = _decodeCommonPageVoData(response.body!);
    return (null, commonVoData);
  } else {
    assert(h == textPlainResponse);
    return (response.body ?? response.statusText ?? '接口请求失败', null);
  }
}

String encodeProtoData<M extends $pb.GeneratedMessage>(M msg) =>
    base64Encode(msg.writeToBuffer());

String encryptProtoData<M extends $pb.GeneratedMessage>(M msg) => base64Encode(
  EncryptedData(data: encryptWith04Prefix(msg.writeToBuffer())).writeToBuffer(),
);
