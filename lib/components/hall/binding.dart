import 'package:get/get.dart';

import 'controller.dart';

class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    Get.lazyPut(()=> TaskHallController());
  }
}
