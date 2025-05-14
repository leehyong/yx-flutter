import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common.dart';

class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint("TaskHallBinding");
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    Get.put(TaskListController(), permanent: true);
  }
}
