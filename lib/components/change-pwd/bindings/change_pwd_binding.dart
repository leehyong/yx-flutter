import 'package:get/get.dart';
import 'package:yx/components/user/controller/change_pwd.dart';


class ChangePwdBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePwdController());
  }
}
