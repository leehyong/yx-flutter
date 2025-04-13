import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/task/bindings/task_creation_binding.dart';
import 'package:yx/components/task/views/detail3.dart';
import 'package:yx/components/work-task/task-info/view.dart';
import 'package:yx/components/work-task/task_hall_view.dart';
import 'package:yx/root/nest_nav_key.dart';

import '../../components/task/bindings/task_binding.dart';
import '../../components/work-task/hall_binding.dart';
import '../../types.dart';

class HallView extends GetView {
  const HallView({super.key});

  @override
  Widget build(context) {
    return Navigator(
      key: Get.nestedKey(NestedNavigatorKeyId.hallId),
      initialRoute: "/hall",
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/hall') {
          return GetPageRoute(
            settings: settings,
            page: () => TaskHallView(),
            bindings: [TaskHallBinding()],
            transition: Transition.topLevel,
          );
        } else if (settings.name == '/hall_detail') {
          // todo
          return GetPageRoute(
            settings: settings,
            bindings: [TaskBinding()],
            page: () => const TaskDetailView3(),
            transition: Transition.fadeIn,
          );
        } else if (settings.name == '/hall/task/publish') {
          final params = settings.arguments! as HallPublishTaskParams;
          return GetPageRoute(
            settings: settings,
            bindings: [TaskCreationBinding()],
            page: () => TaskInfoView(publishTaskParams: params),
            transition: Transition.fadeIn,
          );
        }
        return null;
      },
    );
  }
}
