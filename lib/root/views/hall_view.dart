import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/bindings.dart';
import 'package:yx/components/hall/view.dart';
import 'package:yx/components/work-task/task-info/view.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';

import '../../components/hall/binding.dart';
import '../../types.dart';

class HallView extends GetView {
  const HallView({super.key});

  @override
  Widget build(context) {
    return Navigator(
      key: Get.nestedKey(NestedNavigatorKeyId.hallId),
      initialRoute: WorkTaskRoutes.hallList,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case WorkTaskRoutes.hallList:
            return GetPageRoute(
              settings: settings,
              page: () => TaskHallView(),
              bindings: [TaskHallBinding()],
              transition: Transition.topLevel,
            );
          case WorkTaskRoutes.hallTaskDetail:
            final params = settings.arguments! as WorkTaskPageParams;
            return GetPageRoute(
              settings: settings,
              bindings: [TaskInfoBinding()],
              page: () => TaskInfoView(publishTaskParams: params),
              transition: Transition.leftToRight,
            );

          case WorkTaskRoutes.hallTaskPublish:
            final params = settings.arguments! as WorkTaskPageParams;
            return GetPageRoute(
              settings: settings,
              bindings: [TaskInfoBinding()],
              page: () => TaskInfoView(publishTaskParams: params),
              transition: Transition.fadeIn,
            );
        }
        return null;
      },
    );
  }
}
