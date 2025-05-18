import 'dart:collection';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_header.pb.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/components/work-header/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/toast.dart';

import 'data.dart';
import 'views/select_parent_task.dart';
import 'views/select_task_person.dart';

class TaskInfoController extends GetxController {
  final GlobalKey formKey = GlobalKey<FormState>();
  final GlobalKey<SelectParentTaskState> selectParentTaskKey =
      GlobalKey<SelectParentTaskState>();

  final GlobalKey<SelectTaskPersonState> selectTaskUsersKey =
      GlobalKey<SelectTaskPersonState>();
  final taskId = Int64.ZERO.obs;
  final parentTask = (null as WorkTask?).obs;

  final TaskInfoAction action;

  bool get readOnly => action != TaskInfoAction.write;

  final checkedParentTask = (null as WorkTask?).obs;
  final checkedTaskUsers = (null as List<User>?).obs;

  bool get noParent =>
      parentTask.value == null || parentTask.value!.id == Int64.ZERO;

  bool get isSubmitRelated =>
      action == TaskInfoAction.submit || action == TaskInfoAction.submitDetail;

  TaskInfoController(Int64 parentId, Int64 taskId, this.action) {
    final defaultCat =
        isSubmitRelated && GetPlatform.isMobile
            ? TaskAttributeCategory.submitItem
            : TaskAttributeCategory.basic;
    selectedAttrSet.value = {defaultCat};
    this.taskId.value = taskId;
    if (parentId > Int64.ZERO) {
      task_api.queryWorkTaskInfoById(parentId).then((v) {
        parentTask.value = v;
      });
    }
  }

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

  final saving = false.obs;

  final childrenTask = <WorkTask>[].obs;

  @override
  void onClose() {
    // _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  Future<void> saveTask(SystemTaskStatus status) async {
    if (saving.value) {
      // 限流，避免重复点击
      EasyThrottle.throttle("save-task", Duration(seconds: 1), () {
        errToast("请不要重复操作");
      });
    } else {
      saving.value = true;
      if (taskId.value > Int64.ZERO) {
        final data = _updateYooWorkTask;
        data.task.status = status.index;
        await task_api.updateWorkTask(taskId.value, _updateYooWorkTask);
      } else {
        final data = _newYooWorkTask;
        data.task.status = status.index;
        taskId.value = await task_api.newWorkTask(_newYooWorkTask);
      }
      saving.value = false;
    }
  }

  Int64? _parseDt(String dt) {
    final d = parseDateFromStr(taskPlanStartDtController.text);
    return d != null ? Int64(d.second) : null;
  }

  UpdateYooWorkTask get _updateYooWorkTask => UpdateYooWorkTask(
    task: UpdateWorkTask(
      name: taskNameController.text,
      content: taskContentController.text,
      planStartDt: _parseDt(taskPlanStartDtController.text),
      planEndDt: _parseDt(taskPlanEndDtController.text),
      // 在点击开始时，才变更该属性
      actualPlanStartDt: null,
      // 在点击结束时，才变更该属性
      actualPlanEndDt: null,
      contactor: taskContactorController.text,
      contactPhone: taskContactPhoneController.text,
      credits: double.tryParse(taskCreditsController.text) ?? 0.0,
      creditsStrategy: taskCreditStrategy.value.index,
      submitCycle: taskSubmitCycleStrategy.value.index,
      receiveDeadline:
          _parseDt(taskReceiveDeadlineController.text) ?? Int64.ZERO,
      maxReceiverCount:
          int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
      // 服务器端从jwt中获取并设置
      // organizationId: Int64.ZERO
    ),
    common: CommonYooWorkTask(
      parentTaskId: parentTask.value?.id ?? Int64.ZERO,
      headerIds: Get.find<PublishItemsCrudController>().taskHeaderIds,
    ),
  );

  NewYooWorkTask get _newYooWorkTask => NewYooWorkTask(
    task: NewWorkTask(
      name: taskNameController.text,
      content: taskContentController.text,
      planStartDt: _parseDt(taskPlanStartDtController.text),
      planEndDt: _parseDt(taskPlanEndDtController.text),
      // 在点击开始时，才变更该属性
      actualPlanStartDt: null,
      // 在点击结束时，才变更该属性
      actualPlanEndDt: null,
      contactor: taskContactorController.text,
      contactPhone: taskContactPhoneController.text,
      credits: double.tryParse(taskCreditsController.text) ?? 0.0,
      creditsStrategy: taskCreditStrategy.value.index,
      submitCycle: taskSubmitCycleStrategy.value.index,
      receiveDeadline:
          _parseDt(taskReceiveDeadlineController.text) ?? Int64.ZERO,
      maxReceiverCount:
          int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
    ),
    common: CommonYooWorkTask(
      parentTaskId: parentTask.value?.id ?? Int64.ZERO,
      headerIds: Get.find<PublishItemsCrudController>().taskHeaderIds,
    ),
  );
}

class SubmitTasksController extends GetxController {
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  final isLoadingSubmitItem = DataLoadingStatus.none.obs;

  final taskSubmitItems = (null as List<CusYooHeader>?).obs;
  final _leafTaskSubmitItemsTextEditingControllers =
      HashMap<Int64, TextEditingController>();

  TaskInfoController get taskInfoController => Get.find<TaskInfoController>();

  bool get readOnly => taskInfoController.action == TaskInfoAction.submitDetail;

  TextEditingController getLeafTextEditingController(Int64 headerId) =>
      _leafTaskSubmitItemsTextEditingControllers[headerId]!;

  Future<void> initTaskSubmitItems() async {
    if (isLoadingSubmitItem.value == DataLoadingStatus.loaded) {
      // 避免重复加载
      return;
    }
    isLoadingSubmitItem.value = DataLoadingStatus.loading;
    Future.delayed(Duration(seconds: 1), () {
      // taskSubmitItems.value = submitItems;
      _buildLeafSubmitItemTextEditingController(taskSubmitItems.value!);
      isLoadingSubmitItem.value = DataLoadingStatus.loaded;
    });
  }

  void _buildLeafSubmitItemTextEditingController(List<CusYooHeader> headers) {
    if (readOnly) {
      return;
    }
    for (var entry in headers) {
      if (entry.children.isEmpty) {
        // todo: 给 TextEditingController 填充初始值
        _leafTaskSubmitItemsTextEditingControllers[entry.node.id] =
            TextEditingController();
      } else {
        _buildLeafSubmitItemTextEditingController(entry.children);
      }
    }
  }
}

abstract class _SubmitOneTaskHeaderItemController extends GetxController {
  SubmitTasksController get submitTasksController =>
      Get.find<SubmitTasksController>();
}

class MobileSubmitOneTaskHeaderItemController
    extends _SubmitOneTaskHeaderItemController {
  late final List<SubmitOneWorkTaskHeader> children;

  // late final LinkedHashMap<int, SubmitOneWorkTaskHeader> children;
  MobileSubmitOneTaskHeaderItemController(List<CusYooHeader> children) {
    // this.children = LinkedHashMap<int, SubmitOneWorkTaskHeader>();
    if (children.isEmpty) {
      this.children = [SubmitOneWorkTaskHeader()];
    } else {
      this.children = <SubmitOneWorkTaskHeader>[];
      _buildSubmitWorkHeaders(children);
    }
  }

  void _buildSubmitWorkHeaders(
    List<CusYooHeader> headers, {
    List<WorkHeader>? parents,
  }) {
    for (var entry in headers) {
      final tmpParents = parents ?? [];
      if (entry.children.isEmpty) {
        children.add(SubmitOneWorkTaskHeader(entry.node, tmpParents));
      } else {
        tmpParents.add(entry.node);
        _buildSubmitWorkHeaders(entry.children, parents: tmpParents);
      }
    }
  }
}

class WebSubmitOneTaskHeaderItemController
    extends _SubmitOneTaskHeaderItemController {
  final List<CusYooHeader> children;

  WebSubmitOneTaskHeaderItemController(this.children);
}
