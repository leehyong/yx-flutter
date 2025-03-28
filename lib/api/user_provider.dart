import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:yt_dart/login.pb.dart';
import 'package:yx/utils/proto.dart';
import 'package:yx/vo/user_info_vo.dart';

import '../services/auth_service.dart';
import '../types.dart';
import 'provider.dart';

class UserProvider extends GlobalProvider {
  static UserProvider get instance => Get.find();

  Future<String> getCaptchaCode(String key, int typ) async {
    try {
      final res = await captchaCodeApi(key, typ);
      handleUserLoginTokenToast(() => !res.$1 ? res.$2 : '');
      return res.$1 ? res.$2 : '';
    } catch (e) {
      e.printError(info: e.toString());
      return e.toString();
    }
  }

  Future<(bool, String)> captchaCodeApi(String key, int typ) async {
    final resp = await post<String>(
      "/api/captcha",
      encodeProtoData(SendCaptcha(key: key, typ: typ)),
    );
    final success = resp.isOk;
    if (success) {
      final captchaResp = decodeCommonVoDataFromResponse(resp);
      assert(captchaResp.$1 == null);
      // 本地开发环境返回 :: 分割的验证码文本以及图片形式的验证码以方便测试
      return (true, captchaResp.$2!.msg);
    } else {
      return (false, resp.body ?? resp.statusText ?? '验证码发送失败');
    }
  }

  String handleUserLoginTokenToast(ResponseHandler handler) {
    String err = handler();
    if (err.isNotEmpty) {
      toastification.show(
        type: ToastificationType.error,
        title: Text(err),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
    return err;
  }

  Future<Response<String>> loginApi(
    String user,
    String pwd,
    String captcha,
  ) async => await post<String>(
    "/api/login",
    encryptProtoData(
      Login(captcha: captcha, userLogin: Login_UserLogin(name: user, pwd: pwd)),
    ),
  );

  Future<Response<String>> refreshTokenApi(String token) async =>
      await post<String>(
        "/api/token/refresh",
        encodeProtoData(LoginResponseVo(refreshToken: token)),
      );

  String handleTokenResponse(Response<String> res) {
    final result = decodeCommonVoDataFromResponse(res);
    if (result.$2 != null) {
      if (result.$2!.data.hasValue()) {
        final loginVoData = result.$2!.data.unpackInto(LoginResponseVo());
        final service = AuthService.to;
        service.setLoginInfo(
          loginVoData.accessToken,
          loginVoData.refreshToken,
          loginVoData.username,
        );
      }
      return '';
    } else {
      AuthService.to.resetLoginInfo();
      return result.$1!;
    }
  }

  Future<String> login(String user, String pwd, String captcha) async {
    try {
      final res = await loginApi(user, pwd, captcha);
      return handleUserLoginTokenToast(() => handleTokenResponse(res));
    } catch (e) {
      e.printError(info: e.toString());
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
  Future<List<UserInfoVo>> getUserByOrgId(String orgId) async {
    return [];
    // try {
    //   var res = await get<CommonUserVo>(
    //     "/flyBook/other/get-user-by-org-id",
    //     query: {"organizeId": orgId},
    //     decoder:
    //         (data) => CommonUserVo.fromJson(
    //           data as Map<String, dynamic>,
    //           fromJsonT:
    //               deserializeUserFromList
    //                   as FromJsonFn<List<UserInfoVo>?, List<dynamic>?>,
    //         ),
    //   );
    //   handleCommonToastResponseErr(res, '获取用户信息失败');
    //   return res.body?.data ?? [];
    // } catch (e) {
    //   e.printError(info: e.toString());
    //   return [];
    // }
  }

  Future<bool> refreshAccessToken(String token) async {
    try {
      final res = await refreshTokenApi(token);
      return handleUserLoginTokenToast(
        () => handleTokenResponse(res),
      ).isNotEmpty;
    } catch (e) {
      e.printError(info: e.toString());
    }
    return false;
  }
}
