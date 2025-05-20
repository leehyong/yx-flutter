import 'package:get/get.dart';

import 'controller.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RootTabController());
  }
}
