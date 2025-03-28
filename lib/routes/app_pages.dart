import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../middlewares/auth_middleware.dart';
import '../modules/change-pwd/bindings/change_pwd_binding.dart';
import '../modules/change-pwd/views/change_pwd_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../root/bindings/root_binding.dart';
import '../root/views/root_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.app,
      page: () => const RootView(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      middlewares: [MainMiddleware(), EnsureAuthMiddleware()],
      bindings: [RootBinding()],
    ),
    GetPage(
      middlewares: [
        //only enter this route when not authed
        EnsureNotAuthedMiddleware(),
      ],
      name: Routes.login,
      page: () => const LoginView(),
      bindings: [LoginBinding()],
    ),
    GetPage(
      middlewares: [
        //only enter this route when not authed
        EnsureAuthMiddleware(),
      ],
      name: Routes.changePwd,
      page: () => const ChangePwdView(),
      bindings: [ChangePwdBinding()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      bindings: [SettingsBinding()],
      middlewares: [
        //only enter this route when not authed
        EnsureAuthMiddleware(),
      ],
    ),
  ];
}

class MainMiddleware extends GetMiddleware {
  @override
  void onPageDispose() {
    log('MainMiddleware onPageDispose');
    super.onPageDispose();
  }

  @override
  Widget onPageBuilt(Widget page) {
    log('MainMiddleware onPageBuilt');
    return super.onPageBuilt(page);
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    log('MainMiddleware onPageCalled for route: ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    log('MainMiddleware onBindingsStart');
    return super.onBindingsStart(bindings);
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    log('MainMiddleware onPageBuildStart');

    return super.onPageBuildStart(page);
  }
}
