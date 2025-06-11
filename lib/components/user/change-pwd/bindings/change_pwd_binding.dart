import 'package:get/get.dart';

import '../controller/change_pwd.dart';


class ChangePwdBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePwdController());
  }
}
