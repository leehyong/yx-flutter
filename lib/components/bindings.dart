import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'work-header/controller.dart';

class TaskInfoBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint("TaskInfoBinding");
    Get.lazyPut(() => PublishItemsCrudController());
  }
}