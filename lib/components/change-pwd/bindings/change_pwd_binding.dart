import 'package:get/get.dart';
import 'package:yx/api/user_provider.dart';

import '../../../components/user/controller/change_pwd.dart';

class ChangePwdBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePwdController());
    Get.lazyPut(() => UserProvider());
  }
}
