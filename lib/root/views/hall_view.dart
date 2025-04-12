import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/hall/task_hall_view.dart';
import 'package:yx/components/task/bindings/task_creation_binding.dart';
import 'package:yx/components/task/views/detail3.dart';
import 'package:yx/root/nest_nav_key.dart';

import '../../components/hall/hall_binding.dart';
import '../../components/task/bindings/task_binding.dart';
import '../../components/task/views/task_creation_view.dart';

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
        } else if (settings.name == '/hall_create') {
          return GetPageRoute(
            settings: settings,
            bindings: [TaskCreationBinding()],
            page: () => const TaskCreationView(),
            transition: Transition.fadeIn,
          );
        }
        return null;
      },
    );
  }
}
