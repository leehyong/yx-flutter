import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/cus_user_organization.pb.dart';
import 'package:yt_dart/login.pb.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import 'codes.dart';

Future<String> getCaptchaCode(String key, int typ) async {
  try {
    final res = await captchaCodeApi(key, typ);
    handleUserLoginTokenToast(() => !res.$1 ? res.$2 : '');
    return res.$1 ? res.$2 : '';
  } catch (e) {
    debugPrint('接口 getCaptchaCode 调用失败：$e');
    return e.toString();
  }
}

Future<(bool, String)> captchaCodeApi(String key, int typ) async {
  final resp = await HttpDioService.instance.dio.post<String>(
    "$apiContextPath/captcha",
    data: encodeProtoData(SendCaptcha(key: key, typ: typ)),
  );
  if (isOkResponse(resp)) {
    final captchaResp = decodeCommonVoDataFromResponse(resp);
    assert(captchaResp.$1 == null);
    // 本地开发环境返回 :: 分割的验证码文本以及图片形式的验证码以方便测试
    return (true, captchaResp.$2!.msg);
  } else {
    return (false, resp.data ?? resp.statusMessage ?? '验证码发送失败');
  }
}

Future<Response<String>> loginApi(
  String user,
  String pwd,
  String captcha,
) async => await HttpDioService.instance.dio.post<String>(
  "$apiContextPath/login",
  data: encryptProtoData(
    Login(captcha: captcha, userLogin: Login_UserLogin(name: user, pwd: pwd)),
  ),
);

Future<Response<String>> refreshTokenApi(String token) async =>
    await HttpDioService.instance.dio.post<String>(
      "$apiContextPath/token/refresh",
      data: encodeProtoData(LoginResponseVo(refreshToken: token)),
    );

Future<String> login(String user, String pwd, String captcha) async {
  try {
    final res = await loginApi(user, pwd, captcha);
    return handleUserLoginTokenToast(() => handleTokenResponse(res));
  } catch (e) {
    debugPrint('接口 login 调用失败：$e');
    return e.toString();
  }
}

Future<String> changePwd(String oldPwd, String pwd, {isLog = true}) async {
  return "";
  // try {
  //   var res = await post<CommonVo>(
  //     "/flyBook/auth/change-password",
  //     {"oldPassword": encryptYx(oldPwd), "password": encryptYx(pwd)},
  //     decoder: (data) {
  //       return CommonVo.fromJson(data as Map<String, dynamic>);
  //     },
  //   );
  //   return handleCommonToastResponseErr(res, '修改密码失败');
  // } catch (e) {
  //   e.printError(info: e.toString());
  //   return e.toString();
  // }
}

//
Future<CusUserOrganization?> getOrganizationUsers([bool all=true]) async {
  try {
    final resp = await HttpDioService.instance.dio.get<String>(
      "$apiContextPath/org_user/all?all=$all",
    );
    return handleProtoInstanceVo<CusUserOrganization>(
      resp,
      CusUserOrganization.fromBuffer,
    ).$2;
  } catch (e) {
    debugPrint('接口 getOrganizationUsers 调用失败：$e');
    return null;
  }
}


Future<bool> refreshAccessToken(String token) async {
  try {
    final res = await refreshTokenApi(token);
    return handleUserLoginTokenToast(() => handleTokenResponse(res)).isNotEmpty;
  } catch (e) {
    debugPrint('接口 refreshAccessToken 调用失败：$e');
  }
  return false;
}
