import 'package:yx/components/graph/view.dart';
import 'package:yx/root/bindings/dashboard_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../nest_nav_key.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: Get.nestedKey(NestedNavigatorKeyId.dashboardId),
        initialRoute: "/dashboard",
        onGenerateRoute: (RouteSettings settings){
          if (settings.name == '/dashboard') {
            return GetPageRoute(
              settings: settings,
              page: () => GraphTaskView(),
              bindings: [DashboardBinding()],
              transition: Transition.leftToRight,
            );
          }
          return null;
        });
  }
}
