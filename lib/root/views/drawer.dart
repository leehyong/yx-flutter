import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/tab_controller.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            color: Colors.red,
          ),
          ListTile(
            title: const Text('首页'),
            onTap: () {
              RootTabController.to.setTabIdx(0);
              // Get.toNamed(Routes.home);
              //to close the drawer

              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('工作台'),
            onTap: () {
              RootTabController.to.setTabIdx(1);
              Get.toNamed(Routes.settings);
              //to close the drawer

              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('个人中心'),
            onTap: () {
              RootTabController.to.setTabIdx(2);
              // Get.toNamed(Routes.settings);
              //to close the drawer
              Navigator.of(context).pop();
            },
          ),
          if (AuthService.to.isLoggedInValue)
            ListTile(
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                AuthService.to.logout();
                Get.toNamed(Routes.login);
                //to close the drawer

                // Navigator.of(context).pop();
              },
            ),
          if (!AuthService.to.isLoggedInValue)
            ListTile(
              title: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onTap: () {
                Get.toNamed(Routes.login);
                //to close the drawer

                // Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
