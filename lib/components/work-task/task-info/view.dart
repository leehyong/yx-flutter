import 'dart:math';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/components/work-header/views/header_crud.dart';
import 'package:yx/components/work-header/views/select_submit_item.dart';
import 'package:yx/root/controller.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import '../../common.dart';
import '../../work-header/view.dart';
import '../task-list/view.dart';
import 'views/select_parent_task.dart';
import 'views/select_task_person.dart';
import 'views/submit_task.dart';
import 'views/task_content_history.dart';

class TaskInfoView extends StatefulWidget {
  TaskInfoView({required this.publishTaskParams})
    : super(key: Get.find<RootTabController>().taskInfoViewState);

  final WorkTaskPageParams publishTaskParams;

  TaskOperationCategory get opCategory {
    final routeId = Get.find<RootTabController>().curRouteId;
    var opCategory = TaskOperationCategory.detailTask;
    if (publishTaskParams.opCat == null) {
      if (routeId == NestedNavigatorKeyId.hallId) {
        if (publishTaskParams.task == null || publishTaskParams.task!.id == 0) {
          opCategory = TaskOperationCategory.publishTask;
        }
      } else if (routeId == NestedNavigatorKeyId.homeId) {
        // 我的任务那里的话就是填报任务了，此时 task 肯定满足以下条件
        assert(publishTaskParams.task != null);
        assert(publishTaskParams.task!.id > 0);
        opCategory = TaskOperationCategory.submitTask;
      }
    } else {
      opCategory = publishTaskParams.opCat!;
    }
    return opCategory;
  }

  @override
  TaskInfoViewState createState() => TaskInfoViewState();
}

class TaskInfoViewState extends State<TaskInfoView> {
  final GlobalKey formKey = GlobalKey<FormState>();
  final GlobalKey<SelectParentTaskState> selectParentTaskKey =
      GlobalKey<SelectParentTaskState>();
  final GlobalKey<SubmitTasksViewState> submitTasksViewStateKey =
      GlobalKey<SubmitTasksViewState>();
  final publishItemsViewSimpleCrudState =
      GlobalKey<PublishItemsViewSimpleCrudState>();
  final selectSubmitItemViewState = GlobalKey<SelectSubmitItemViewState>();
  final publishSubmitItemsCrudViewState =
      GlobalKey<PublishSubmitItemsCrudViewState>();

  final GlobalKey<SelectTaskUserState> selectTaskUsersKey =
      GlobalKey<SelectTaskUserState>();
  Int64 taskId = Int64.ZERO;
  Int64 parentId = Int64.ZERO;
  WorkTask? parentTask;

  WorkTask? checkedParentTask;
  List<User>? checkedTaskUsers;

  TaskInfoAction get action {
    switch (widget.opCategory) {
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

  @override
  void initState() {
    super.initState();
    taskId = widget.publishTaskParams.task?.id ?? Int64.ZERO;
    parentId = widget.publishTaskParams.parentId;
    _handleTaskChange(widget.publishTaskParams.task);
    _handleParentIdChange(parentId);
    // 批量更新上述的所有修改
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('TaskInfoViewState_dispose');
    // WidgetsBinding.instance.addPostFrameCallback((v) {
    Get.find<RootTabController>().taskListViewState.currentState
        ?.removeSecondLayer();
    // });
  }

  bool get enableSelectChildrenTasks => action == TaskInfoAction.detail;

  bool get noParent => parentId == Int64.ZERO;

  bool get isSubmitRelated =>
      action == TaskInfoAction.submit || action == TaskInfoAction.submitDetail;

  bool get readOnly => action != TaskInfoAction.write;

  void resetTask() {
    //  设置输入框的默认值
    taskNameController.text = '';
    taskContentController.text = '';
    taskPlanStartDtController.text = '';
    taskPlanEndDtController.text = '';
    taskContactorController.text = '';
    taskContactPhoneController.text = '';
    taskCreditsController.text = '';
    taskReceiveDeadlineController.text = '';
    taskReceiverQuotaLimitedController.text = '';
    taskId = Int64.ZERO;
    taskCreditStrategy = TaskCreditStrategy.latest;
    taskSubmitCycleStrategy = TaskSubmitCycleStrategy.week;
    taskReceiveStrategy = ReceiveTaskStrategy.twoWaySelection;
  }

  void _initTask(WorkTask v) {
    //  设置输入框的默认值
    taskNameController.text = v.name;
    taskContentController.text = v.content;
    taskPlanStartDtController.text = inputDateTxtFromSecond(v.planStartDt);
    taskPlanEndDtController.text = inputDateTxtFromSecond(v.planEndDt);
    taskContactorController.text = v.contactor;
    taskContactPhoneController.text = v.contactPhone;
    taskCreditsController.text = v.credits > 0 ? v.credits.toString() : '';
    taskReceiveDeadlineController.text = inputDateTimeTxtFromSecond(
      v.receiveDeadline,
    );
    taskReceiverQuotaLimitedController.text = v.maxReceiverCount.toString();
    taskCreditStrategy = TaskCreditStrategy.values[v.creditsStrategy];
    taskSubmitCycleStrategy = TaskSubmitCycleStrategy.values[v.submitCycle];
    taskReceiveStrategy = ReceiveTaskStrategy.values[v.receiveStrategy];
  }

  SubmitTasksViewState? get submitTasksViewState =>
      submitTasksViewStateKey.currentState;

  Future<void> _handleTaskChange(WorkTask? v) async {
    if (v != null) {
      _initTask(v);
      // 查询用户关联的用户
      if (v.receiveStrategy != ReceiveTaskStrategy.freeSelection.index) {
        task_api.taskRelSelectedUsers(v.id).then((v) {
          setState(() {
            checkedTaskUsers = v;
          });
        });
      } else {
        checkedTaskUsers = null;
      }
    } else {
      resetTask();
      checkedTaskUsers = null;
    }
  }

  Future<void> _handleParentIdChange(Int64 v) async {
    if (parentId > Int64.ZERO) {
      task_api.queryWorkTaskInfoById(parentId).then((v) {
        setState(() {
          parentTask = v;
        });
      });
    } else {
      parentTask = null;
    }
  }

  void handleOperationCategoryChange(TaskOperationCategory v) {
    final defaultCat =
        isSubmitRelated && GetPlatform.isMobile
            ? TaskAttributeCategory.submitItem
            : TaskAttributeCategory.basic;
    selectedAttrSet = {defaultCat};
  }

  RootTabController get rootTabController => Get.find<RootTabController>();

  void saveModification(ModifyWarningCategory modification) {
    rootTabController.addModification(() async {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        saveTask();
      });
    }, modification);
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
  ReceiveTaskStrategy taskReceiveStrategy = ReceiveTaskStrategy.twoWaySelection;
  TaskSubmitCycleStrategy taskSubmitCycleStrategy =
      TaskSubmitCycleStrategy.week;
  TaskCreditStrategy taskCreditStrategy = TaskCreditStrategy.latest;
  Set<TaskAttributeCategory> selectedAttrSet = {TaskAttributeCategory.basic};

  bool saving = false;

  final childrenTask = <WorkTask>[].obs;

  List<String> get selectedPersons =>
      checkedTaskUsers?.map((u) => u.name).toList() ?? [];

  Future<bool> saveTask({
    SystemTaskStatus? status,
    bool clearModifications = false,
  }) async {
    if (saving) {
      // 限流，避免重复点击
      EasyThrottle.throttle("save-task", Duration(seconds: 1), () {
        errToast("请不要重复操作");
      });
      return false;
    } else {
      setState(() {
        saving = true;
      });
      bool success = false;
      if (taskId > Int64.ZERO) {
        final data = _updateYooWorkTask(status);
        final ret = await task_api.updateWorkTask(taskId, data);
        success = ret == null;
      } else {
        final data = _newYooWorkTask(status);
        final taskId_ = await task_api.newWorkTask(data);
        setState(() {
          taskId = taskId_;
        });
        success = taskId > Int64.ZERO;
      }
      if (success && status == SystemTaskStatus.published) {
        okToast("发布成功");
      }
      setState(() {
        saving = false;
      });
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
        creditsStrategy: taskCreditStrategy.index,
        submitCycle: taskSubmitCycleStrategy.index,
        receiveDeadline: parseDateTimeFromSecond(
          taskReceiveDeadlineController.text,
        ),
        receiveStrategy: taskReceiveStrategy.index,
        maxReceiverCount:
            int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
        status: status?.index ?? widget.publishTaskParams.task?.status,
        // 服务器端从jwt中获取并设置
        // organizationId: Int64.ZERO
      ),
      common: CommonYooWorkTask(
        parentTaskId: parentId,
        headerIds: publishSubmitItemsCrudViewState.currentState!.taskHeaderIds,
        userIds: checkedTaskUsers?.map((user) => user.id).toList(),
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
        creditsStrategy: taskCreditStrategy.index,
        submitCycle: taskSubmitCycleStrategy.index,
        receiveStrategy: taskReceiveStrategy.index,
        receiveDeadline:
            parseDateTimeFromSecond(taskReceiveDeadlineController.text) ??
            Int64.ZERO,
        maxReceiverCount:
            int.tryParse(taskReceiverQuotaLimitedController.text) ?? 0,
        status: status?.index,
      ),

      common: CommonYooWorkTask(
        parentTaskId: parentId,
        headerIds: publishSubmitItemsCrudViewState.currentState!.taskHeaderIds,
        userIds: checkedTaskUsers?.map((user) => user.id).toList(),
      ),
    );
  }

  Widget get title {
    final children = <Widget>[];
    switch (widget.opCategory) {
      case TaskOperationCategory.detailTask:
      case TaskOperationCategory.submitDetailTask:
        children.add(
          const Text(
            '详情:',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
        break;
      case TaskOperationCategory.publishTask:
        if (widget.publishTaskParams.parentId > Int64.ZERO) {
          children.add(
            Row(
              children: [
                Text('新建', style: defaultTitleStyle),
                Text(
                  parentTask?.name ?? '',
                  style: defaultTitleStyle.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('的子任务', style: defaultTitleStyle),
              ],
            ),
          );
        } else {
          children.add(
            Text(widget.opCategory.i18name, style: defaultTitleStyle),
          );
        }
        break;
      case TaskOperationCategory.submitTask:
        children.add(
          const Text(
            '填报:',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
        break;
      case TaskOperationCategory.delegateTask:
        children.add(
          const Text(
            '委派:',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
        break;
      case TaskOperationCategory.updateTask:
        children.add(
          const Text(
            '修改:',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
        break;
    }
    if (widget.publishTaskParams.task != null) {
      children.add(
        Container(
          padding: EdgeInsets.only(bottom: 2, left: 3), // 控制下划线与文本的距离
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: defaultTitleStyle.color!,
                width: 1, // 下划线粗细
              ),
            ),
          ),
          child: Text(
            widget.publishTaskParams.task!.name,
            style: defaultTitleStyle,
          ),
        ),
      );
    }
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // 返回时， 重设上次选择的任务类型
          rootTabController.warnConfirmModifying(
            finalCb: () async {
              // taskListController.curCat = {publishTaskParams.catList};
              // 清空该告警信息，以免重复提示
              rootTabController.clearModifications();
              Navigator.of(context).pop();
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
          actions:
              widget.opCategory == TaskOperationCategory.submitTask
                  ? [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500, // 背景色
                        foregroundColor: Colors.white,
                        // 文字颜色
                      ),
                      onPressed: () {
                        debugPrint("新增");
                        submitTasksViewState?.handleTaskSubmitAction(
                          TaskSubmitAction.add,
                        );
                      },
                      child: const Text('新增'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint("保存");
                        submitTasksViewState?.handleTaskSubmitAction(
                          TaskSubmitAction.save,
                        );
                      },
                      child: const Text('保存'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400, // 背景色
                        foregroundColor: Colors.black,
                        // 文字颜色
                      ),
                      onPressed: () {
                        WoltModalSheet.show(
                          onModalDismissedWithBarrierTap: () {
                            Navigator.of(context).maybePop();
                          },
                          useSafeArea: true,
                          context: context,
                          modalTypeBuilder: woltModalType,
                          pageListBuilder:
                              (modalSheetContext) => [
                                WoltModalSheetPage(
                                  topBarTitle: Center(
                                    child: Text(
                                      "历史填报",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  hasTopBarLayer: true,
                                  // hasSabGradient: false,
                                  isTopBarLayerAlwaysVisible: true,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          GetPlatform.isMobile ? 500 : 800,
                                    ),
                                    child: RepaintBoundary(
                                      child: TaskContentHistoryView(
                                        task: widget.publishTaskParams.task!,
                                      ),
                                    ),
                                  ),
                                ),
                                // child: ,
                              ],
                        );
                      },
                      // child: Row(children: [const Text('提交'), Icon(Icons.check)]),
                      child: const Text('历史'),
                    ),
                  ]
                  : null,
        ),

        body: Padding(
          padding: EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: isBigScreen(context) ? 10 : 4,
          ),
          child: _buildTaskInfoView(context),
        ),
      ),
    );
  }

  Widget _buildTaskInfoView(BuildContext context) {
    return Form(
      key: formKey,
      child: RepaintBoundary(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _buildRelationAttributes(context),
            ),
            SizedBox(height: 10),
            Expanded(child: _buildTaskRelates(context)),
            _buildInfoActions(context),
            // Align(alignment: Alignment.center, child: actions,),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoActions(BuildContext context) {
    Widget actions = SizedBox.shrink();
    switch (action) {
      case TaskInfoAction.write:
        actions = _buildActions(context);
        break;
      case TaskInfoAction.delegate:
        actions = _buildDelegateActions(context);
      default:
        break;
    }
    return actions;
  }

  List<TaskAttributeCategory> segmentedBtnCategories(BuildContext context) {
    if (isBigScreen(context)) {
      return [
        TaskAttributeCategory.basic,
        TaskAttributeCategory.parentTask,
        TaskAttributeCategory.childrenTask,
      ];
    }
    return isSubmitRelated
        ? [
          TaskAttributeCategory.submitItem,
          TaskAttributeCategory.basic,
          TaskAttributeCategory.parentTask,
          TaskAttributeCategory.childrenTask,
        ]
        : TaskAttributeCategory.values;
  }

  Widget _buildRelationAttributes(BuildContext context) {
    return SegmentedButton(
      segments:
          segmentedBtnCategories(context)
              .map(
                (e) => ButtonSegment(
                  value: e,
                  label: Text(e.i18name, softWrap: false, maxLines: 1),
                ),
              )
              .toList(),
      onSelectionChanged: (s) {
        setState(() {
          selectedAttrSet = s;
        });
        final first = s.first;
        // bool needUpdatePushItemsController = false;
        switch (first) {
          case TaskAttributeCategory.childrenTask:
            commonSetTaskListInfo(
              parentId: taskId,
              defaultCat: TaskListCategory.childrenTaskInfo,
            );
            break;
          // case TaskAttributeCategory.submitItem:
          //   needUpdatePushItemsController = true;
          //   break;
          // case TaskAttributeCategory.basic:
          //   needUpdatePushItemsController = isBigScreen(context);
          default:
            break;
        }
        // if (needUpdatePushItemsController) {
        //   Get.find<PublishItemsCrudController>().curTaskId = c
        // }
      },
      selected: selectedAttrSet,
      multiSelectionEnabled: false,
    );
  }

  Widget _buildTaskRelates(BuildContext context) {
    switch (selectedAttrSet.first) {
      case TaskAttributeCategory.basic:
        if (isBigScreen(context)) {
          return Row(
            children: [
              SizedBox(width: 4),
              Expanded(child: _publishTaskBasicInfoView(context)),
              SizedBox(width: 4),
              Expanded(
                child:
                    isSubmitRelated
                        ? SubmitTasksView(readOnly: readOnly)
                        : PublishSubmitItemsCrudView(),
              ),
              SizedBox(width: 4),
            ],
          );
        }
        return _publishTaskBasicInfoView(context);

      case TaskAttributeCategory.submitItem:
        return isSubmitRelated
            ? SubmitTasksView(readOnly: readOnly)
            : PublishSubmitItemsCrudView();

      case TaskAttributeCategory.parentTask:
        return _publishTaskParentInfoView(context);
      case TaskAttributeCategory.childrenTask:
        return _publishTaskChildrenInfoView(context);
    }
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isBigScreen(context)
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
      spacing: 10,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50, // 背景色
            foregroundColor: Colors.black,
            padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            debugPrint("草稿");
            centerLoadingModal(context, () async {
              WidgetsBinding.instance.addPostFrameCallback((v) {
                saveTask(
                  status: SystemTaskStatus.initial,
                  clearModifications: true,
                );
              });
            });
          },
          child: const Text("存为草稿"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 背景色
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            debugPrint("发布");
            centerLoadingModal(context, () async {
              WidgetsBinding.instance.addPostFrameCallback((v) {
                saveTask(
                  status: SystemTaskStatus.published,
                  clearModifications: true,
                ).then((v) {
                  if (v && context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                });
              });
            });
          },
          child: const Text("发布"),
        ),
      ],
    );
  }

  Widget _buildDelegateActions(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isBigScreen(context)
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
      spacing: 10,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50, // 背景色
            foregroundColor: Colors.black,
            padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            debugPrint("拒绝");
          },
          child: const Text("拒绝"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 背景色
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            debugPrint("接受");
          },
          child: const Text("接受"),
        ),
      ],
    );
  }

  Widget _publishTaskParentInfoView(BuildContext context) {
    return Column(
      children: [
        // 已有父任务的任务就不能再选择父任务了
        if (!readOnly && noParent)
          Align(
            alignment:
                GetPlatform.isMobile
                    ? Alignment.centerRight
                    : Alignment.topLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50, // 背景色
                foregroundColor: Colors.black,
                padding: EdgeInsets.all(4),
                // 文字颜色
              ),
              onPressed: () {
                // todo 什么样的任务才能选为父任务呢 ？
                WoltModalSheet.show(
                  onModalDismissedWithBarrierTap: () {
                    Navigator.of(context).maybePop();
                  },
                  useSafeArea: true,
                  context: context,
                  modalTypeBuilder: woltModalType,
                  pageListBuilder:
                      (modalSheetContext) => [
                        WoltModalSheetPage(
                          topBarTitle: Center(
                            child: Text(
                              "请选择父任务",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          hasTopBarLayer: true,
                          // hasSabGradient: false,
                          isTopBarLayerAlwaysVisible: true,
                          leadingNavBarWidget: IconButton(
                            padding: const EdgeInsets.all(4),
                            icon: Text("重置"),
                            onPressed: () {
                              Navigator.of(modalSheetContext).pop();
                            },
                          ),
                          trailingNavBarWidget: IconButton(
                            padding: const EdgeInsets.all(4),
                            icon: Text(
                              "确定",
                              style: TextStyle(color: Colors.blue),
                            ),
                            // icon: Text("确定"),
                            onPressed: () {
                              setState(() {
                                checkedParentTask =
                                    selectParentTaskKey
                                        .currentState
                                        ?.curCheckedTask;
                              });
                              Navigator.of(modalSheetContext).maybePop();
                            },
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: GetPlatform.isMobile ? 500 : 800,
                            ),
                            child: RepaintBoundary(
                              child: SelectParentTaskView(
                                key: selectParentTaskKey,
                              ),
                            ),
                          ),
                        ),
                        // child: ,
                      ],
                );
              },
              child: const Text("选择"),
            ),
          ),
        noParent
            ? emptyWidget(context)
            :
            // 展示父任务的信息
            Align(
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constrains) {
                  final width =
                      !GetPlatform.isMobile
                          ? min(500.0, constrains.maxWidth)
                          : constrains.maxWidth;
                  return SizedBox(
                    width: width,
                    height: width * 0.4,
                    // todo: 是否需要查询 left 、history 属性
                    child: OneTaskCardView(
                      userTaskHis: UserTaskHistory(
                        task: parentTask!,
                        total: 0,
                        history: [],
                      ),
                      taskCategory: TaskListCategory.parentTaskInfo,
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _publishTaskChildrenInfoView(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: 0.0, // 0.0 隐藏，1.0 显示。通过透明度控制显示，隐藏时仍占据布局空间
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50, // 背景色
              foregroundColor: Colors.black,
              padding: EdgeInsets.all(4),
              // 文字颜色
            ),
            onPressed: () {},
            child: const Text("选择"),
          ),
        ),
        noParent
            ? emptyWidget(context)
            : Expanded(
              child: TaskListView(
                showSegBtns: false,
                // parentId: parentId,
                // defaultCat: TaskListCategory.childrenTaskInfo,
              ),
            ),
      ],
    );
  }

  Widget _buildTaskName(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      maxLines: 2,
      readOnly: readOnly,
      controller: taskNameController,
      decoration: InputDecoration(
        enabled: !readOnly,
        label: Row(
          spacing: 4,
          children: [
            const Text('名称'),
            const Text(
              '*',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        icon: Icon(Icons.table_bar),
      ),
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: (v) {
        // todo 查询数据库看看名称是否重复了
        if (v!.trim().isEmpty) {
          return '名称不能为空';
        }
        saveModification(ModifyWarningCategory.basic);
        return null;
      },
    );
  }

  Widget _buildTaskContent(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
      readOnly: readOnly,
      // 固定显示 5 行
      expands: false,
      // 禁止无限扩展
      controller: taskContentController,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        enabled: !readOnly,
        label: Row(
          spacing: 4,
          children: [
            const Text('内容'),
            const Text(
              '*',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        icon: Icon(Icons.text_snippet_outlined),
      ),
      validator: (v) {
        // 暂不需要验证
        if (v!.trim().isEmpty) {
          return '内容不能为空';
        }
        saveModification(ModifyWarningCategory.basic);

        return null;
      },
    );
  }

  Widget _buildTaskContacts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: taskContactorController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '联系人',
              icon: Icon(Icons.person),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.phone,
            controller: taskContactPhoneController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '联系电话',
              icon: Icon(Icons.phone_android),
            ),
            validator: (v) {
              // 验证手机号
              if (!isValidPhone(v!)) {
                return phoneRegErrorTxt;
              }
              saveModification(ModifyWarningCategory.basic);
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaybeIgnorePointerDropDown(Widget w) =>
      IgnorePointer(ignoring: readOnly, child: w);

  Widget _buildTaskSubmitCycleCredits(BuildContext context) {
    return DropdownButtonFormField<TaskSubmitCycleStrategy>(
      value: taskSubmitCycleStrategy,
      decoration: InputDecoration(
        // enabled: !readOnly,
        label: Row(
          spacing: 4,
          children: [
            Text('任务填报方式'),
            Text(
              '*',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        icon: Icon(Icons.gas_meter),
      ),
      items:
          TaskSubmitCycleStrategy.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.i18name)),
              )
              .toList(),
      onChanged: (v) {
        if (readOnly) {
          return;
        }
        setState(() {
          taskSubmitCycleStrategy = v!;
        });
        saveModification(ModifyWarningCategory.options);
      },
    );
  }

  Widget _buildTaskCredits(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMaybeIgnorePointerDropDown(
            DropdownButtonFormField(
              value: taskCreditStrategy,
              decoration: InputDecoration(
                labelText: '积分方式',
                icon: Icon(Icons.gas_meter),
              ),
              items:
                  TaskCreditStrategy.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.i18name),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (readOnly) {
                  return;
                }
                setState(() {
                  taskCreditStrategy = v!;
                });
                saveModification(ModifyWarningCategory.options);
              },
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            keyboardType: TextInputType.numberWithOptions(),
            controller: taskCreditsController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '任务积分',
              icon: Icon(Icons.diamond_outlined),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
            onChanged: (v) {
              saveModification(ModifyWarningCategory.basic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskReceiversLimitedQuota(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      keyboardType: TextInputType.numberWithOptions(),
      controller: taskReceiverQuotaLimitedController,
      decoration: InputDecoration(
        enabled: !readOnly,
        labelText: '名额限制',
        suffix: Text("人"),
        icon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        // 暂不需要验证
        return null;
      },
      onChanged: (v) {
        saveModification(ModifyWarningCategory.basic);
      },
    );
  }

  Widget _buildTaskReceivers(BuildContext context) {
    final List<Widget> children = [];
    final selectedPersons_ = selectedPersons;

    if (selectedPersons_.isNotEmpty) {
      const maxCnt = 3;
      final persons = selectedPersons_.sublist(
        0,
        min(maxCnt, selectedPersons_.length),
      );
      children.addAll(
        persons.map(
          (p) => Container(
            padding: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.blue.shade400,
            ),
            child: Tooltip(
              message: p,
              triggerMode: GetPlatform.isMobile ? TooltipTriggerMode.tap : null,
              preferBelow: false,
              child: Text(
                p.substring(0, min(5, p.length)),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
      children.add(
        Row(
          children: [
            Text(selectedPersons_.length > maxCnt ? "等" : "共"),
            Text(
              selectedPersons_.length.toString(),
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            const Text("人"),
          ],
        ),
      );
    }
    return Row(
      spacing: 14,
      children: [
        Icon(Icons.people),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50, // 背景色
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 8),
            // 文字颜色
          ),
          onPressed: () {
            if (readOnly) {
              return;
            }
            WoltModalSheet.show(
              onModalDismissedWithBarrierTap: () {
                Navigator.of(context).maybePop();
              },
              useSafeArea: true,
              context: context,
              modalTypeBuilder: woltModalType,
              pageListBuilder:
                  (modalSheetContext) => [
                    WoltModalSheetPage(
                      topBarTitle: Center(
                        child: Text(
                          "请选择人员",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      hasTopBarLayer: true,
                      // hasSabGradient: false,
                      isTopBarLayerAlwaysVisible: true,
                      leadingNavBarWidget: IconButton(
                        padding: const EdgeInsets.all(4),
                        icon: Text("取消"),
                        onPressed: () {
                          Navigator.of(modalSheetContext).pop();
                        },
                      ),
                      trailingNavBarWidget: IconButton(
                        padding: const EdgeInsets.all(4),
                        icon: Text("确定", style: TextStyle(color: Colors.blue)),
                        // icon: Text("确定"),
                        onPressed: () {
                          final old = checkedTaskUsers ?? <User>[];
                          final newUsers =
                              selectTaskUsersKey
                                  .currentState
                                  ?.curTaskSelectedUsers;
                          if (old
                              .map((u) => u.id)
                              .toSet()
                              .difference(
                                newUsers?.map((e) => e.id).toSet() ?? <Int64>{},
                              )
                              .isNotEmpty) {
                            saveModification(ModifyWarningCategory.participant);
                          }
                          setState(() {
                            checkedTaskUsers = newUsers;
                          });
                          Navigator.of(modalSheetContext).maybePop();
                        },
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: GetPlatform.isMobile ? 500 : 800,
                        ),
                        child: RepaintBoundary(
                          child: SelectTaskPersonView(key: selectTaskUsersKey),
                        ),
                      ),
                    ),
                    // child: ,
                  ],
            );
          },
          child: Text(selectedPersons.isNotEmpty ? '已选择' : '选择人员'),
        ),
        if (children.isNotEmpty)
          Expanded(child: Row(spacing: 4, children: children)),
      ],
    );
  }

  Widget _buildReceiveTask(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMaybeIgnorePointerDropDown(
            DropdownButtonFormField(
              value: taskReceiveStrategy,
              decoration: InputDecoration(
                labelText: '领取方式',
                icon: Icon(Icons.gas_meter),
              ),
              items:
                  ReceiveTaskStrategy.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.i18name),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (readOnly) {
                  return;
                }
                saveModification(ModifyWarningCategory.basic);
                setState(() {
                  taskReceiveStrategy = v!;
                  taskReceiverQuotaLimitedController.text = '';
                });
              },
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            keyboardType: TextInputType.datetime,
            onTap: () async {
              if (readOnly) {
                return;
              }
              final dt = parseDatetimeFromStr(
                taskReceiveDeadlineController.text,
              );
              DateTime date = await showCusDateTimePicker(context, dt: dt);
              taskReceiveDeadlineController.text = defaultDateTimeFormat1
                  .format(date);
              saveModification(ModifyWarningCategory.dateTime);

              // debugPrint("selectdt${date.toIso8601String()}");
            },
            controller: taskReceiveDeadlineController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '领取截止时间',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
            onChanged: (v) {
              saveModification(ModifyWarningCategory.dateTime);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDt(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            onTap: () async {
              final dt = parseDateFromStr(taskPlanStartDtController.text);
              DateTime date = await showCusDatePicker(context, dt: dt);
              taskPlanStartDtController.text = defaultDateFormat.format(date);
              saveModification(ModifyWarningCategory.date);
            },
            keyboardType: TextInputType.datetime,
            controller: taskPlanStartDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '开始日期',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              if (taskPlanEndDtController.text.isNotEmpty &&
                  v!.compareTo(taskPlanEndDtController.text) > 0) {
                return "开始日期不大于结束日期";
              }
              return null;
            },
            onChanged: (v) {
              saveModification(ModifyWarningCategory.date);
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            onTap: () async {
              if (readOnly) {
                return;
              }
              final dt = parseDateFromStr(taskPlanEndDtController.text);
              DateTime date = await showCusDatePicker(context, dt: dt);
              taskPlanEndDtController.text = defaultDateFormat.format(date);
              saveModification(ModifyWarningCategory.date);
            },

            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: taskPlanEndDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '结束日期',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              if (taskPlanStartDtController.text.isNotEmpty &&
                  v!.compareTo(taskPlanStartDtController.text) < 0) {
                return "结束日期不小于开始日期";
              }
              return null;
            },
            onChanged: (v) {
              saveModification(ModifyWarningCategory.dateTime);
            },
          ),
        ),
      ],
    );
  }

  Widget _publishTaskBasicInfoView(BuildContext context) {
    final widgets = [
      _buildTaskName(context),
      _buildTaskContent(context),
      _buildMaybeIgnorePointerDropDown(_buildTaskSubmitCycleCredits(context)),
      _buildTaskContacts(context),
      _buildPlanDt(context),
      _buildReceiveTask(context),
    ];
    if (taskReceiveStrategy == ReceiveTaskStrategy.freeSelection) {
      widgets.add(_buildTaskReceiversLimitedQuota(context));
    } else {
      widgets.add(_buildTaskReceivers(context));
    }
    widgets.add(_buildTaskCredits(context));
    // return GetBuilder(builder: (controller) => Column(children: widgets));
    return Column(children: widgets);
  }
}
