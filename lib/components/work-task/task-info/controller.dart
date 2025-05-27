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
import 'package:yx/root/controller.dart';
import 'package:yx/root/nest_nav_key.dart';
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

  final GlobalKey<SelectTaskUserState> selectTaskUsersKey =
      GlobalKey<SelectTaskUserState>();
  final task = (null as WorkTask?).obs;
  final taskId = Int64.ZERO.obs;
  final parentTask = (null as WorkTask?).obs;
  final parentId = Int64.ZERO.obs;

  final opCategory = TaskOperationCategory.detailTask.obs;

  final checkedParentTask = (null as WorkTask?).obs;
  final checkedTaskUsers = (null as List<User>?).obs;

  TaskInfoAction get action {
    switch (opCategory.value) {
      case TaskOperationCategory.detailTask:
        return TaskInfoAction.detail;
      case TaskOperationCategory.submitTask:
        return TaskInfoAction.submit;
      case TaskOperationCategory.delegateTask:
        return TaskInfoAction.delegate;
      case TaskOperationCategory.submitDetailTask:
        return TaskInfoAction.submitDetail;
      default:
        return TaskInfoAction.write;
    }
  }

  bool get enableSelectChildrenTasks => action == TaskInfoAction.detail;

  bool get noParent => parentId.value == Int64.ZERO;

  bool get isSubmitRelated =>
      action == TaskInfoAction.submit || action == TaskInfoAction.submitDetail;

  bool get readOnly => action != TaskInfoAction.write;

  void resetTask() {
    task.value = null;
    taskId.value = Int64.ZERO;
    //  设置输入框的默认值
    taskNameController.text = '';
    taskContentController.text = '';
    taskPlanStartDtController.text = '';
    taskPlanEndDtController.text = '';
    taskContactorController.text = '';
    taskContactPhoneController.text = '';
    taskCreditsController.text = '';
    taskCreditStrategy.value = TaskCreditStrategy.latest;
    taskSubmitCycleStrategy.value = TaskSubmitCycleStrategy.week;
    taskReceiveStrategy.value = ReceiveTaskStrategy.twoWaySelection;
    taskReceiveDeadlineController.text = '';
    taskReceiverQuotaLimitedController.text = '';
  }

  void resetAll() {
    resetTask();
    parentTask.value = null;
  }

  void initTask(WorkTask v) {
    taskId.value = task.value!.id;
    //  设置输入框的默认值
    taskNameController.text = v.name;
    taskContentController.text = v.content;
    taskPlanStartDtController.text = inputDateTxtFromSecond(v.planStartDt);
    taskPlanEndDtController.text = inputDateTxtFromSecond(v.planEndDt);
    taskContactorController.text = v.contactor;
    taskContactPhoneController.text = v.contactPhone;
    taskCreditsController.text = v.credits > 0 ? v.credits.toString() : '';
    taskCreditStrategy.value = TaskCreditStrategy.values[v.creditsStrategy];
    taskSubmitCycleStrategy.value =
        TaskSubmitCycleStrategy.values[v.submitCycle];
    taskReceiveStrategy.value = ReceiveTaskStrategy.values[v.receiveStrategy];
    taskReceiveDeadlineController.text = inputDateTimeTxtFromSecond(
      v.receiveDeadline,
    );
    taskReceiverQuotaLimitedController.text = v.maxReceiverCount.toString();
  }

  @override
  void onInit() {
    super.onInit();
    ever(task, (v) {
      if (v != null) {
        initTask(v);
        // 查询用户关联的用户
        if (v.receiveStrategy != ReceiveTaskStrategy.freeSelection.index) {
          task_api.taskRelSelectedUsers(v.id).then((v) {
            checkedTaskUsers.value = v;
          });
        } else {
          checkedTaskUsers.value = null;
        }
      } else {
        resetTask();
        checkedTaskUsers.value = null;
      }
    });
    ever(parentId, (v) {
      if (parentId.value > Int64.ZERO) {
        task_api.queryWorkTaskInfoById(parentId.value).then((v) {
          parentTask.value = v;
        });
      } else {
        parentTask.value = null;
      }
    });
    ever(opCategory, (_) {
      final defaultCat =
          isSubmitRelated && GetPlatform.isMobile
              ? TaskAttributeCategory.submitItem
              : TaskAttributeCategory.basic;
      selectedAttrSet.value = {defaultCat};
    });
  }

  RootTabController get rootTabController => Get.find<RootTabController>();

  void saveModification(ModifyWarningCategory modification) {
    Get.find<RootTabController>().addModification(saveTask, modification);
  }

  // Int64 get parentId => parentTask.value?.id ?? Int64.ZERO;
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

  final saving = false.obs;

  final childrenTask = <WorkTask>[].obs;

  List<String> get selectedPersons =>
      checkedTaskUsers.value?.map((u) => u.name).toList() ?? [];

  Future<bool> saveTask({
    SystemTaskStatus? status,
    bool clearModifications = false,
  }) async {
    if (saving.value) {
      // 限流，避免重复点击
      EasyThrottle.throttle("save-task", Duration(seconds: 1), () {
        errToast("请不要重复操作");
      });
      return false;
    } else {
      saving.value = true;
      bool success = false;
      if (taskId.value > Int64.ZERO) {
        final data = _updateYooWorkTask(status);
        debugPrint(data.toDebugString());
        final ret = await task_api.updateWorkTask(taskId.value, data);
        success = ret == null;
      } else {
        final data = _newYooWorkTask(status);
        debugPrint(data.toDebugString());
        taskId.value = await task_api.newWorkTask(data);
        success = taskId.value > Int64.ZERO;
      }
      if (success && status == SystemTaskStatus.published) {
        okToast("发布成功");
      }
      saving.value = false;
      if (clearModifications) {
        // WidgetsBinding.instance.addPostFrameCallback((d){});
        rootTabController.clearModifications();
      }
      return success;
    }
  }

  UpdateYooWorkTask _updateYooWorkTask(SystemTaskStatus? status) {
    return UpdateYooWorkTask(
      task: UpdateWorkTask(
        name: taskNameController.text,
        content: taskContentController.text,
        planStartDt: parseDateFromSecond(taskPlanStartDtController.text),
        planEndDt: parseDateFromSecond(taskPlanEndDtController.text),
        // 在点击开始时，才变更该属性
        actualPlanStartDt: null,
        // 在点击结束时，才变更该属性
        actualPlanEndDt: null,
        contactor: taskContactorController.text,
        contactPhone: taskContactPhoneController.text,
        credits: double.tryParse(taskCreditsController.text) ?? 0.0,
        creditsStrategy: taskCreditStrategy.value.index,
        submitCycle: taskSubmitCycleStrategy.value.index,
        receiveDeadline: parseDateTimeFromSecond(
          taskReceiveDeadlineController.text,
        ),
        receiveStrategy: taskReceiveStrategy.value.index,
        maxReceiverCount:
            int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
        status: status?.index ?? task.value?.status,
        // 服务器端从jwt中获取并设置
        // organizationId: Int64.ZERO
      ),
      common: CommonYooWorkTask(
        parentTaskId: parentId.value,
        headerIds: Get.find<PublishItemsCrudController>().taskHeaderIds,
        userIds: checkedTaskUsers.value?.map((user) => user.id).toList(),
      ),
    );
  }

  NewYooWorkTask _newYooWorkTask(SystemTaskStatus? status) {
    return NewYooWorkTask(
      task: NewWorkTask(
        name: taskNameController.text,
        content: taskContentController.text,
        planStartDt: parseDateFromSecond(taskPlanStartDtController.text),
        planEndDt: parseDateFromSecond(taskPlanEndDtController.text),
        // 在点击开始时，才变更该属性
        actualPlanStartDt: null,
        // 在点击结束时，才变更该属性
        actualPlanEndDt: null,
        contactor: taskContactorController.text,
        contactPhone: taskContactPhoneController.text,
        credits: double.tryParse(taskCreditsController.text) ?? 0.0,
        creditsStrategy: taskCreditStrategy.value.index,
        submitCycle: taskSubmitCycleStrategy.value.index,
        receiveStrategy: taskReceiveStrategy.value.index,
        receiveDeadline:
            parseDateTimeFromSecond(taskReceiveDeadlineController.text) ??
            Int64.ZERO,
        maxReceiverCount:
            int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
        status: status?.index,
      ),

      common: CommonYooWorkTask(
        parentTaskId: parentId.value,
        headerIds: Get.find<PublishItemsCrudController>().taskHeaderIds,
        userIds: checkedTaskUsers.value?.map((user) => user.id).toList(),
      ),
    );
  }
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
      _buildLeafSubmitItemTextEditingController(taskSubmitItems.value ?? []);
      isLoadingSubmitItem.value = DataLoadingStatus.loaded;
    });
  }

  Future<void> saveTaskContent() async {
    //   todo: 调用相关接口
  }

  void saveModification() {
    Get.find<RootTabController>().addModification(
      saveTaskContent,
      ModifyWarningCategory.submitContent,
    );
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

void setCurTaskInfo(WorkTaskPageParams param) {
  final controller = Get.find<TaskInfoController>();
  controller.task.value = param.task;
  controller.parentId.value = param.parentId;
  controller.opCategory.value = getTaskInfoOperationCategory(param);
}

TaskOperationCategory getTaskInfoOperationCategory(WorkTaskPageParams param) {
  final routeId = Get.find<RootTabController>().curRouteId;
  var opCategory = TaskOperationCategory.detailTask;
  if (param.opCat == null) {
    if (routeId == NestedNavigatorKeyId.hallId) {
      if (param.task == null || param.task!.id == 0) {
        opCategory = TaskOperationCategory.publishTask;
      }
    } else if (routeId == NestedNavigatorKeyId.homeId) {
      // 我的任务那里的话就是填报任务了，此时 task 肯定满足以下条件
      assert(param.task != null);
      assert(param.task!.id > 0);
      opCategory = TaskOperationCategory.submitTask;
    }
  } else {
    opCategory = param.opCat!;
  }
  return opCategory;
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
