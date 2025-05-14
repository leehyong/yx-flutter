import 'package:get/get.dart';

import '../common.dart';

class TaskHomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    Get.lazyPut(()=> CommonTaskListCatController());
  }
}
