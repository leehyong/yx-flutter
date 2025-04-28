import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import '../../work-header/data.dart';
import 'data.dart';
import 'views/select_parent_task.dart';
import 'views/select_task_person.dart';

class SubmitTasksController extends GetxController {
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  final isLoadingSubmitItem = false.obs;

}

class TaskInfoController extends GetxController {
  final GlobalKey formKey = GlobalKey<FormState>();
  final GlobalKey<SelectParentTaskState> selectParentTaskKey =
      GlobalKey<SelectParentTaskState>();

  final GlobalKey<SelectTaskPersonState> selectTaskUsersKey =
      GlobalKey<SelectTaskPersonState>();
  late final Int64 taskId;
  late final Int64 parentId;
  final checkedParentTask = (null as WorkTask?).obs;
  final checkedTaskUsers = (null as List<User>?).obs;

  TaskInfoController(this.parentId, this.taskId);

  final taskNameController = TextEditingController();
  final taskContentController = TextEditingController();
  final taskPlanStartDtController = TextEditingController();
  final taskPlanEndDtController = TextEditingController();
  final taskReceiveDeadlineController = TextEditingController();
  final taskReceiverQuotaLimitedController = TextEditingController();
  final taskContactorController = TextEditingController();
  final taskContactPhoneController = TextEditingController();
  final taskCreditsController = TextEditingController();
  final taskReceiveStrategy = ReceiveTaskStrategy.twoWaySelection.obs;
  final taskSubmitCycleStrategy = TaskSubmitCycleStrategy.week.obs;
  final taskCreditStrategy = TaskCreditStrategy.latest.obs;
  final selectedAttrSet = {TaskAttributeCategory.basic}.obs;
  final selectedPersons = <String>["1恶趣味", "恶趣味www", "恶趣味", "2dad服"].obs;

  final childrenTask =
      <WorkTask>[
        WorkTask(
          id: Int64(2),
          name: '大模型11',
          content: "22dadafwqeqweqf是生生世世",
          planStartDt: Int64(1744525638),
          planEndDt: Int64(1744612038),
          receiveDeadline: Int64(1744439238),
          contactor: "赵生",
          contactPhone: "15522900013",
          credits: 88,
          receiveStrategy: 0,
        ),
        WorkTask(
          id: Int64(2),
          name: '大模型huahu2',
          content: "22dadafwqeqweqf是生生信息世世",
          planStartDt: Int64(1744957638),
          planEndDt: Int64(1745821638),
          receiveDeadline: Int64(1745303238),
          contactor: "马六生",
          contactPhone: "15521020013",
          credits: 1028,
          receiveStrategy: 1,
        ),
        WorkTask(
          id: Int64(3),
          name: '大模型huahu密码',
          content: "22dadafwqeqweqf是生生信息世世",
          planStartDt: Int64(1746080838),
          planEndDt: Int64(1746944838),
          receiveDeadline: Int64(1745216838),
          contactor: "马六",
          contactPhone: "15521020011",
          credits: 328,
          receiveStrategy: 2,
        ),
      ].obs;
  final parentTask =
      WorkTask(
        id: Int64(1),
        name: '大模型11',
        content: "22dadafwqeqweqf是生生世世",
        planStartDt: Int64(1744525638),
        planEndDt: Int64(1744612038),
        receiveDeadline: Int64(1744439238),
        contactor: "赵生",
        contactPhone: "15522900013",
        credits: 88,
        receiveStrategy: 0,
      ).obs;

  @override
  void onClose() {
    // _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }
}

class SubmitOneTaskHeaderItemController extends GetxController {
  late final List<SubmitOneWorkTaskHeader> children;

  // late final LinkedHashMap<int, SubmitOneWorkTaskHeader> children;

  SubmitOneTaskHeaderItemController(List<WorkHeaderTree> children) {
    // this.children = LinkedHashMap<int, SubmitOneWorkTaskHeader>();
    if (children.isEmpty) {
      this.children = [SubmitOneWorkTaskHeader()];
    } else {
      this.children = <SubmitOneWorkTaskHeader>[];
      _buildSubmitWorkHeaders(children);
    }
  }

  void _buildSubmitWorkHeaders(
    List<WorkHeaderTree> headers, {
    List<WorkHeader>? parents,
  }) {
    for (var entry in headers.asMap().entries) {
      final tmpParents = parents ?? [];
      if (entry.value.children.isEmpty) {
        children.add(SubmitOneWorkTaskHeader(entry.value.task, tmpParents));
      } else {
        tmpParents.add(entry.value.task);
        _buildSubmitWorkHeaders(entry.value.children, parents: tmpParents);
      }
    }
  }
}
