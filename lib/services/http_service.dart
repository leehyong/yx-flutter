import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:toastification/toastification.dart';
import 'package:yt_dart/login.pb.dart';
import 'package:yx/services/auth_service.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/proto.dart';

import '../config.dart';
import 'adapter/web.dart' if (dart.library.io) 'adapter/native.dart';

class HttpDioService extends GetxService {
  static HttpDioService get instance => Get.find();

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      baseUrl: AppConfig.apiServer,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    dio.httpClientAdapter = YooHttpClientAdapter.adapter;
    final authService = AuthService.instance;
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (requestOptions, handler) {
          debugPrint('''
[onRequest] ${requestOptions.hashCode} / time: ${DateTime.now().toIso8601String()}
\tPath: ${requestOptions.path}
\tHeaders: ${requestOptions.headers}
          ''');
          // In case, you have 'refresh_token' and needs to refresh your 'access_token',
          // request a new 'access_token' and update from here.
          requestOptions.headers[accessTokenStr] = authService.accessToken;
          return handler.next(requestOptions);
        },

        onResponse: (response, handler) {
          debugPrint('''
[onResponse] ${response.requestOptions.hashCode} / time: ${DateTime.now().toIso8601String()}
\tStatus: ${response.statusCode}
\tData: ${response.data}
        ''');

          return handler.resolve(response);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          debugPrint('''
[onError] ${error.requestOptions.hashCode} / time: ${DateTime.now().toIso8601String()}
\tStatus: $statusCode
          ''');

          // This example only handles the '401' status code,
          // The more complex scenario should handle more status codes e.g. '403', '404', etc.
          if (statusCode != 401) {
            return handler.resolve(error.response!);
          }

          // To prevent repeated requests to the 'Authentication Server'
          // to update our 'access_token' with parallel requests,
          // we need to compare with the previously requested 'access_token'.
          final requestedAccessToken =
              error.requestOptions.headers[accessTokenStr];
          if (requestedAccessToken == authService.accessToken) {
            final tokenRefreshDio =
                Dio()..options.baseUrl = AppConfig.apiServer;

            final response = await tokenRefreshDio.post(
              "/api/token/refresh",
              data: encodeProtoData(
                LoginResponseVo(refreshToken: authService.refreshToken),
              ),
            );
            tokenRefreshDio.close();

            // Treat codes other than 2XX as rejected.
            if (!isOkResponse(response)) {
              return handler.reject(error);
            }
            final errMsg = handleTokenResponse(response as Response<String>);
            if (errMsg.isNotEmpty) {
              return handler.reject(error);
            }
          }

          /// The authorization has been resolved so and try again with the request.
          final retried = await dio.fetch(
            error.requestOptions
              ..headers = {accessTokenStr: authService.accessToken},
          );

          // Treat codes other than 2XX as rejected.
          if (!isOkResponse(retried)) {
            return handler.reject(error);
          }

          return handler.resolve(error.response!);
        },
      ),
    );
    // LogInterceptor 拦截器来自动打印请求和响应等日志：
    // LogInterceptor 应该保持最后一个被添加到拦截器中， 否则在它之后进行处理的拦截器修改的内容将无法体现。
    dio.interceptors.add(LogInterceptor(responseBody: true)); // 不输出响应内容体
  }
}

String handleTokenResponse(Response<String> res, {bool check=false}) {
  final result = decodeCommonVoDataFromResponse(res);
  if (result.$2 != null) {
    if (result.$2!.data.hasValue()) {
      final loginVoData = result.$2!.data.unpackInto(LoginResponseVo());
      // 检查条件是否满足
      if (check && loginVoData.orgId <= 0 && loginVoData.userId <= 0) {
        return '';
      }
      AuthService.instance.setLoginInfo(
        loginVoData.accessToken,
        loginVoData.refreshToken,
        UserInfo(
          username: loginVoData.username,
          userId: loginVoData.userId,
          orgId: loginVoData.orgId,
          orgName: loginVoData.orgName,
          roles: loginVoData.roles,
          permissions: loginVoData.permissions,
        ),
      );
    }
    return '';
  } else {
    AuthService.instance.resetLoginInfo();
    return result.$1!;
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
