import 'package:get/get.dart';
import 'package:yx/api/user_provider.dart';
import 'package:yx/config.dart';
import 'package:yx/services/auth_service.dart';
import 'package:yx/utils/toast.dart';
import 'package:yx/vo/common_vo.dart';

import 'codes.dart';

class GlobalProvider extends GetConnect {
  bool isJwtCodeRefreshing = false;

  @override
  void onInit() {
    // All request will pass to jsonEncode so CasesModel.fromJson()
    httpClient.baseUrl = apiServer;

    httpClient.timeout = Duration(seconds: 60);
    // baseUrl = 'https://api.covid19api.com'; // It define baseUrl to
    // Http and websockets if used with no [httpClient] instance

    // It's will attach 'apikey' property on header from all requests
    httpClient.addRequestModifier<dynamic>((request) async {
      AuthService authService = AuthService.to;
      if (request.headers[xxCusHeaderOfAccessToken] !=
          xxCusHeaderOfAccessToken && isJwtCodeRefreshing) {
        // 正在刷新token的话， 先等前面的接口请求完成之后开始， 但不阻塞 refreshAccessToken 方法
        // while (isJwtCodeRefreshing) {
          await Future.delayed(Duration(milliseconds: 100));
        // }
      }
      request.headers[accessTokenStr] = authService.accessToken;
      // Set the header
      return request;
    });
    httpClient.addResponseModifier<dynamic>((request, response) async {
      final statusCode = response.status.code;
      if (statusCode == jwtCodeExpired && !isJwtCodeRefreshing) {
        isJwtCodeRefreshing = true;
        // 刷新token
        final success = await UserProvider.instance.refreshAccessToken(
          AuthService.to.accessToken,
        );
        isJwtCodeRefreshing = false;
        if (success) {
          // 成功后才重新发送请求
          return httpClient.send(request);
        }
      }
      return response;
    });

    //Autenticator will be called 3 times if HttpStatus is
    //HttpStatus.unauthorized
    httpClient.maxAuthRetries = 3;
  }

  bool handleCommonToastResponse(
    Response<CommonVo<dynamic, dynamic>?> res,
    String defaultMsg,
  ) {
    return handleCommonToastResponseErr(res, defaultMsg).isEmpty;
  }

  String handleCommonToastResponseErr(
    Response<CommonVo<dynamic, dynamic>?> res,
    String defaultMsg,
  ) {
    final err = !res.isOk || res.body?.code != responseCodeOk;
    var errMsg = '';
    if (err) {
      errMsg = res.body?.message ?? res.statusText ?? defaultMsg;
      errToast(errMsg);
    }
    return errMsg;
  }
}
