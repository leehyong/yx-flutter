import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'package:toastification/toastification.dart';

void main() {
  // await LoggerManager().initLogger();
  return runApp(
    ToastificationWrapper(
      child: GetMaterialApp(
        enableLog: true,
        title: "Application",
        theme: ThemeData(),
        useInheritedMediaQuery: true,
        initialBinding: BindingsBuilder(() {
          Get.put(AuthService());
        }),
        getPages: AppPages.routes,
        initialRoute: Routes.login,
        onGenerateRoute: (RouteSettings settings) {
          // 重新设置密码
          if (settings.name == '/') {
            var service = AuthService.to;
            if (service.isWeak) {
              Get.offAndToNamed("/change-pwd");
            }
          }
        },
      ),
    ),
  );
}
