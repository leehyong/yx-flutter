import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/phone_login_controller.dart';
import '../controllers/user_login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => PhoneLoginController());
    Get.lazyPut(() => UserLoginController());
  }
}
