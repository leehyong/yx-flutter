import 'package:yx/api/provider.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/root_controller.dart';
import '../controllers/tab_controller.dart';
import '../controllers/web_menu_controller.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RootController());
    Get.lazyPut(() => RootTabController());
    // Get.lazyPut(() => HomeController());
    // Get.lazyPut(() => ProfileController());
    // Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => RootWebMenuController());
  }
}
