import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tab_controller.dart';
import '../controllers/web_menu_controller.dart';

class RootWebMenuView extends GetView<RootWebMenuController> {
  const RootWebMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationRail(
        selectedLabelTextStyle: TextStyle(color: Colors.red),
        // leading: const Icon(Icons.menu_open,color: Colors.grey,),
        leading: IconButton(
          tooltip: '菜单',
          onPressed: () => controller.toggleMenuOpen(),
          icon:
              controller.menuOpen.value
                  ? const Icon(Icons.menu_open, color: Colors.red)
                  : const Icon(Icons.menu, color: Colors.grey),
        ),
        destinations: List.from(
          RootTabController.menus.map(
            (ele) => NavigationRailDestination(
              icon: ele['icon'],
              label: Text(ele['label']),
            ),
          ),
        ), //[
        // extended: true,
        elevation: 2,
        extended: controller.menuOpen.value,
        selectedIndex: RootTabController.to.curTab.value,
        onDestinationSelected: (idx) => RootTabController.to.setTabIdx(idx),
      ),
    );
  }
}
