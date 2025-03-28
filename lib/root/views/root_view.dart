import 'package:yx/root/controllers/tab_controller.dart';
import 'package:yx/root/views/mobile_tab_view.dart';
import 'package:yx/root/views/web_menu_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/root_controller.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          GetPlatform.isWeb
              ? Row(
                children: [
                  RootWebMenuView(),
                  Expanded(child: Obx(() => RootTabController.to.curTabView)),
                ],
              )
              : Obx(() => RootTabController.to.curTabView),
      bottomNavigationBar: GetPlatform.isMobile ? RootBottomTabView() : null,
    );
  }
}
