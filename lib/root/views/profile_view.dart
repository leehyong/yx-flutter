import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/user/center/view.dart';
import 'package:yx/components/user/change-pwd/bindings/change_pwd_binding.dart';
import 'package:yx/components/user/change-pwd/view.dart';
import 'package:yx/components/user/change-pwd/views/change_pwd_comp.dart';
import 'package:yx/components/user/organization/view.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(context) {
    return Navigator(
      key: Get.nestedKey(NestedNavigatorKeyId.userCenterId),
      initialRoute: UserProfileRoutes.center,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case UserProfileRoutes.center:
            return GetPageRoute(
              settings: settings,
              page: () => PersonalCenterView(),
              transition: Transition.topLevel,
            );
          case UserProfileRoutes.organization:
            final params = settings.arguments! as UserCenterPageParams;
            return GetPageRoute(
              settings: settings,
              page: () => OrganizationView(params: params),
              transition: Transition.topLevel,
            );
          case UserProfileRoutes.registerOrganization:
            final params = settings.arguments! as UserCenterPageParams;
            return GetPageRoute(
              settings: settings,
              page: () => RegisterOrganizationView(params: params),
              transition: Transition.leftToRight,
            );
          case UserProfileRoutes.changePwd:
            final params = settings.arguments! as UserCenterPageParams;
            return GetPageRoute(
              settings: settings,
              page: () => ChangePwdVIew(params: params),
              transition: Transition.rightToLeftWithFade,
            );
        }
        return null;
      },
    );
  }
}
