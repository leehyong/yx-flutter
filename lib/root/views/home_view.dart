import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/bindings.dart';
import 'package:yx/components/home/binding.dart';
import 'package:yx/components/home/view.dart';
import 'package:yx/components/work-task/task-info/view.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';

import '../controllers/home_controller.dart';
import '../nest_nav_key.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(context) {
    return Navigator(
      key: Get.nestedKey(NestedNavigatorKeyId.homeId),
      initialRoute: WorkTaskRoutes.homeList,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case WorkTaskRoutes.homeList:
            return GetPageRoute(
              settings: settings,
              page: () => TaskHomeView(),
              bindings: [TaskHomeBinding()],
              transition: Transition.topLevel,
            );
          case WorkTaskRoutes.homeTaskSubmit:
          case WorkTaskRoutes.homeTaskDetail:
            final params = settings.arguments! as WorkTaskPageParams;
            return GetPageRoute(
              settings: settings,
              bindings: [TaskInfoBinding()],
              page: () => TaskInfoView(publishTaskParams: params),
              transition: Transition.leftToRight,
            );
        }
        return null;
      },
    );
  }
}