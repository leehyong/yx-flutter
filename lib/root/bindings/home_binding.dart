import 'package:yx/api/duty_provider.dart';
import 'package:yx/api/user_provider.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProvider());
    Get.lazyPut(() => DutyProvider());
    Get.lazyPut(()=> HomeController());
  }
}
