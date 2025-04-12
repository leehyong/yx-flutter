import 'package:get/get.dart';
import 'package:yx/api/duty_provider.dart';
import 'package:yx/api/user_provider.dart';

import 'hall_controller.dart';

class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProvider());
    Get.lazyPut(() => DutyProvider());
    Get.lazyPut(()=> TaskHallController());
  }
}
