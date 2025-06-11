import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/user/center/view.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';

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
              bindings: [],
              transition: Transition.topLevel,
            );
        }
        return null;
      },
    );
  }
}
