import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/services/auth_service.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ProfileView is working', style: TextStyle(fontSize: 20)),
          const Hero(tag: 'heroLogo', child: FlutterLogo()),
          MaterialButton(
            child: const Text('Show a test dialog'),
            onPressed: () {
              //shows a dialog
              Get.defaultDialog(
                title: 'Test Dialog !!',
                barrierDismissible: true,
              );
            },
          ),
          MaterialButton(
            child: const Text('退出'),
            onPressed: () {
              //shows a dialog
              AuthService.instance.logout();
            },
          ),
        ],
      ),
    );
  }
}
