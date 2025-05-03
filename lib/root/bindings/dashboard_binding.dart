import 'package:get/get.dart';

import '../../components/graph/controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GraphTaskController());
    Get.lazyPut(() => DashboardController());
  }
}
