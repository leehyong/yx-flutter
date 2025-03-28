import 'package:yx/api/user_provider.dart';
import 'package:yx/components/graph/graph-comment/controller.dart';
import 'package:get/get.dart';

import '../../api/comment_provider.dart';
import '../../api/department_provider.dart';
import '../../api/graph_provider.dart';
import '../../components/graph/controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProvider());
    Get.lazyPut(() => DepartmentProvider());
    Get.lazyPut(() => TaskCommentProvider());
    Get.lazyPut(() => GraphTaskCommentController());
    Get.lazyPut(() => GraphTaskProvider());
    Get.lazyPut(() => GraphTaskController());
    Get.lazyPut(()=>DashboardController());
  }
}
