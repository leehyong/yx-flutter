import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint("TaskHallBinding");
    // Get.put(TaskInfoController(), permanent: true);
    // Get.lazyPut(() => TaskInfoController());
  }
}


