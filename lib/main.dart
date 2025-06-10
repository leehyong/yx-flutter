import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toastification/toastification.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/http_service.dart';
import 'types.dart';

void main() async {
  // await LoggerManager().initLogger();
  await GetStorage.init(userStorage);
  return runApp(
    ToastificationWrapper(
      //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
      child: GetMaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate, // Material 组件本地化
          GlobalWidgetsLocalizations.delegate, // 基础 Widget 本地化（如文本方向）
          GlobalCupertinoLocalizations.delegate, // iOS 风格组件本地化（可选）
        ],
        supportedLocales: [
          const Locale('zh', 'CN'), // 中文（简体）
          const Locale('en', 'US'), // 英文（美国）
        ],
        enableLog: true,
        title: "悦享管",
        theme: ThemeData(),
        useInheritedMediaQuery: true,
        initialBinding: BindingsBuilder(() {
          Get.put(AuthService());
          Get.put(HttpDioService());
        }),
        getPages: AppPages.routes,
        initialRoute: Routes.login,
        onGenerateRoute: (RouteSettings settings) {
          // 重新设置密码
          if (settings.name == Routes.app) {
            var service = AuthService.instance;
            if (service.isWeak) {
              Get.offAndToNamed(Routes.changePwd);
            }
          }
        },
      ),
    ),
  );
}
