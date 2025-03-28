import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toastification/toastification.dart';

import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'types.dart';

void main() async {
  // await LoggerManager().initLogger();
  await GetStorage.init(userStorage);
  return runApp(
    ToastificationWrapper(
      child: GetMaterialApp(
        enableLog: true,
        title: "悦享管",
        theme: ThemeData(),
        useInheritedMediaQuery: true,
        initialBinding: BindingsBuilder(() {
          Get.put(AuthService());
        }),
        getPages: AppPages.routes,
        initialRoute: Routes.app,
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
