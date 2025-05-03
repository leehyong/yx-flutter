import 'package:get/get.dart';
import 'package:yx/vo/duty_vo.dart';


class HomeController extends GetxController {
  //移动端显示展示的任务类型
  final selectedMobileTaskType = '全部'.obs;
  List<String> taskTypeNameList = ["日常工作", "临时工作", "重点任务"];
  Set<int> selectedSet = {1};
  // 定义一个变量来记录当前选中的按钮
  var selectedValue = 0.obs;
  RxMap<String, List<DutyVo>> multiDutyMap = <String, List<DutyVo>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initTaskList();
  }

  Future<void> initTaskList() async {
    // 初始化 multiDutyMap，确保每个任务类型都有一个空列表
    for (var taskType in taskTypeNameList) {
      multiDutyMap[taskType] = [];
    }
  }

  Future<void> distributeTasksByType(List<DutyVo> dutyList) async {
    for (var duty in dutyList) {
      // 如果 task.type 为 null，则默认为 "日常工作"
      String dutyType = duty.dutyType ?? "日常工作";
      // 将任务添加到对应类型的列表中
      multiDutyMap[dutyType]?.add(duty);
    }
  }
}
