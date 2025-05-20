import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../../common.dart';
import '../../work-header/view.dart';
import '../task-list/view.dart';
import 'controller.dart';
import 'views/select_parent_task.dart';
import 'views/select_task_person.dart';
import 'views/submit_task.dart';

class TaskInfoView extends GetView<TaskInfoController> {
  const TaskInfoView({
    super.key,
    // required this.taskCategory,
    required this.publishTaskParams,
  });

  final WorkTaskPageParams publishTaskParams;

  TaskOperationCategory get opCategory =>
      getTaskInfoOperationCategory(publishTaskParams);

  Widget get title {
    final children = <Widget>[];
    switch (opCategory) {
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
        children.add(Text(opCategory.i18name, style: defaultTitleStyle));
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
    if (publishTaskParams.task != null) {
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
          child: Text(publishTaskParams.task!.name, style: defaultTitleStyle),
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
          final taskListController = Get.find<TaskListController>();
          // 返回时， 重设上次选择的任务类型
          controller.rootTabController.warnConfirmModifying(
            finalCb: () async {
              taskListController.curCat.value = {publishTaskParams.catList};
              // 清空该告警信息，以免重复提示
              controller.rootTabController.clearModifications();
              Navigator.of(context).pop();
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
          actions: [
            if (opCategory == TaskOperationCategory.submitTask)
              ElevatedButton(
                onPressed: () {
                  debugPrint("提交");
                },
                // child: Row(children: [const Text('提交'), Icon(Icons.check)]),
                child: Row(children: [const Text('提交'), Icon(Icons.check)]),
              ),
          ],
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
      key: controller.formKey,
      child: RepaintBoundary(
        child: Obx(
          () => Column(
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
      ),
    );
  }

  Widget _buildInfoActions(BuildContext context) {
    Widget actions = SizedBox.shrink();
    switch (controller.action) {
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
    return controller.isSubmitRelated
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
        controller.selectedAttrSet.value = s;
        final first = s.first;
        // bool needUpdatePushItemsController = false;
        switch (first) {
          case TaskAttributeCategory.childrenTask:
            commonSetTaskListInfo(
              parentId: controller.parentTask.value?.id.toInt() ?? 0,
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
      selected: controller.selectedAttrSet.value,
      multiSelectionEnabled: false,
    );
  }

  Widget _buildTaskRelates(BuildContext context) {
    switch (controller.selectedAttrSet.first) {
      case TaskAttributeCategory.basic:
        if (isBigScreen(context)) {
          return Row(
            children: [
              SizedBox(width: 4),
              Expanded(child: _publishTaskBasicInfoView(context)),
              SizedBox(width: 4),
              Expanded(
                child:
                    controller.isSubmitRelated
                        ? SubmitTasksView(controller.readOnly)
                        : PublishSubmitItemsCrudView(
                          // controller.taskId.value,
                          // readOnly,
                        ),
              ),
              SizedBox(width: 4),
            ],
          );
        }
        return _publishTaskBasicInfoView(context);

      case TaskAttributeCategory.submitItem:
        return controller.isSubmitRelated
            ? SubmitTasksView(controller.readOnly)
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
              await controller.saveTask(
                status: SystemTaskStatus.initial,
                clearModifications: true,
              );
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
            bool success = false;
            centerLoadingModal(context, () async {
              success = await controller.saveTask(
                status: SystemTaskStatus.published,
                clearModifications: true,
              );
            }).then((v) {
              if (success && context.mounted) {
                Navigator.of(context).maybePop();
              }
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
        if (!controller.readOnly && controller.noParent)
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
                              controller.checkedParentTask.value =
                                  controller
                                      .selectParentTaskKey
                                      .currentState
                                      ?.curCheckedTask;
                              Navigator.of(modalSheetContext).maybePop();
                            },
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: GetPlatform.isMobile ? 500 : 800,
                            ),
                            child: RepaintBoundary(
                              child: SelectParentTaskView(
                                key: controller.selectParentTaskKey,
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
        controller.noParent
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
                    child: OneTaskView(
                      task: controller.parentTask.value!,
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
        controller.noParent
            ? emptyWidget(context)
            : Expanded(
              child: TaskListView(
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
      readOnly: controller.readOnly,
      controller: controller.taskNameController,
      decoration: InputDecoration(
        enabled: !controller.readOnly,
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
        return null;
      },
      onChanged: (_) {
        controller.saveModification(ModifyWarningCategory.basic);
      },
    );
  }

  Widget _buildTaskContent(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
      readOnly: controller.readOnly,
      // 固定显示 5 行
      expands: false,
      // 禁止无限扩展
      controller: controller.taskContentController,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        enabled: !controller.readOnly,
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
        return null;
      },
      onChanged: (_) {
        controller.saveModification(ModifyWarningCategory.basic);
      },
    );
  }

  Widget _buildTaskContacts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: controller.taskContactorController,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
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
            controller: controller.taskContactPhoneController,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
              labelText: '联系电话',
              icon: Icon(Icons.phone_android),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
            onChanged: (_) {
              controller.saveModification(ModifyWarningCategory.basic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaybeIgnorePointerDropDown(Widget w) =>
      IgnorePointer(ignoring: controller.readOnly, child: w);

  Widget _buildTaskSubmitCycleCredits(BuildContext context) {
    return DropdownButtonFormField<TaskSubmitCycleStrategy>(
      value: controller.taskSubmitCycleStrategy.value,
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
        if (controller.readOnly) {
          return;
        }
        controller.taskSubmitCycleStrategy.value = v!;
        controller.saveModification(ModifyWarningCategory.options);
      },
    );
  }

  Widget _buildTaskCredits(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMaybeIgnorePointerDropDown(
            DropdownButtonFormField(
              value: controller.taskCreditStrategy.value,
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
                if (controller.readOnly) {
                  return;
                }
                controller.taskCreditStrategy.value = v!;
                controller.saveModification(ModifyWarningCategory.options);
              },
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: controller.readOnly,
            keyboardType: TextInputType.numberWithOptions(),
            controller: controller.taskCreditsController,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
              labelText: '任务积分',
              icon: Icon(Icons.diamond_outlined),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
            onChanged: (v) {
              controller.saveModification(ModifyWarningCategory.basic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskReceiversLimitedQuota(BuildContext context) {
    return TextFormField(
      readOnly: controller.readOnly,
      keyboardType: TextInputType.numberWithOptions(),
      controller: controller.taskReceiverQuotaLimitedController,
      decoration: InputDecoration(
        enabled: !controller.readOnly,
        labelText: '名额限制',
        suffix: Text("人"),
        icon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        // 暂不需要验证
        return null;
      },
      onChanged: (v) {
        controller.saveModification(ModifyWarningCategory.basic);
      },
    );
  }

  Widget _buildTaskReceivers(BuildContext context) {
    final List<Widget> children = [];
    if (controller.selectedPersons.value.isNotEmpty) {
      const maxCnt = 3;
      final cnt = controller.selectedPersons.value.length;
      final persons = controller.selectedPersons.value.sublist(
        0,
        min(maxCnt, cnt),
      );
      children.add(const Text("已选择"));
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
            Text(cnt > maxCnt ? "等" : "共"),
            Text(
              controller.selectedPersons.value.length.toString(),
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
            if (controller.readOnly) {
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
                        icon: Text("重置"),
                        onPressed: () {
                          Navigator.of(modalSheetContext).pop();
                        },
                      ),
                      trailingNavBarWidget: IconButton(
                        padding: const EdgeInsets.all(4),
                        icon: Text("确定", style: TextStyle(color: Colors.blue)),
                        // icon: Text("确定"),
                        onPressed: () {
                          final old = controller.checkedTaskUsers.value ?? [];
                          final new_ =
                              controller
                                  .selectTaskUsersKey
                                  .currentState
                                  ?.selectedUsers ??
                              [];
                          if (old
                              .map((u) => u.id)
                              .toSet()
                              .difference(new_.map((u) => u.id).toSet())
                              .isNotEmpty) {
                            controller.saveModification(
                              ModifyWarningCategory.participant,
                            );
                          }
                          controller.checkedTaskUsers.value = new_;
                          Navigator.of(modalSheetContext).maybePop();
                        },
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: GetPlatform.isMobile ? 500 : 800,
                        ),
                        child: RepaintBoundary(
                          child: SelectTaskPersonView(
                            key: controller.selectTaskUsersKey,
                          ),
                        ),
                      ),
                    ),
                    // child: ,
                  ],
            );
          },
          child: const Text("选择人员"),
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
              value: controller.taskReceiveStrategy.value,
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
                if (controller.readOnly) {
                  return;
                }
                controller.saveModification(ModifyWarningCategory.basic);
                controller.taskReceiveStrategy.value = v!;
              },
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: controller.readOnly,
            keyboardType: TextInputType.datetime,
            onTap: () async {
              if (controller.readOnly) {
                return;
              }
              final dt = parseDatetimeFromStr(
                controller.taskReceiveDeadlineController.text,
              );
              DateTime date = await showCusDateTimePicker(context, dt: dt);
              controller
                  .taskReceiveDeadlineController
                  .text = defaultDateTimeFormat1.format(date);
              controller.saveModification(ModifyWarningCategory.dateTime);

              // debugPrint("selectdt${date.toIso8601String()}");
            },
            controller: controller.taskReceiveDeadlineController,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
              labelText: '领取截止时间',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
            onChanged: (v) {
              controller.saveModification(ModifyWarningCategory.dateTime);
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
            readOnly: controller.readOnly,
            onTap: () async {
              final dt = parseDateFromStr(
                controller.taskPlanStartDtController.text,
              );
              DateTime date = await showCusDatePicker(context, dt: dt);
              controller.taskPlanStartDtController.text = defaultDateFormat
                  .format(date);
              controller.saveModification(ModifyWarningCategory.date);
            },
            keyboardType: TextInputType.datetime,
            controller: controller.taskPlanStartDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
              labelText: '开始日期',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              if (controller.taskPlanEndDtController.text.isNotEmpty &&
                  v!.compareTo(controller.taskPlanEndDtController.text) > 0) {
                return "开始日期不大于结束日期";
              }
              return null;
            },
            onChanged: (v) {
              controller.saveModification(ModifyWarningCategory.date);
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: controller.readOnly,
            onTap: () async {
              if (controller.readOnly) {
                return;
              }
              final dt = parseDateFromStr(
                controller.taskPlanEndDtController.text,
              );
              DateTime date = await showCusDatePicker(context, dt: dt);
              controller.taskPlanEndDtController.text = defaultDateFormat
                  .format(date);
              controller.saveModification(ModifyWarningCategory.date);
            },

            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: controller.taskPlanEndDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !controller.readOnly,
              labelText: '结束日期',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              if (controller.taskPlanStartDtController.text.isNotEmpty &&
                  v!.compareTo(controller.taskPlanStartDtController.text) < 0) {
                return "结束日期不小于开始日期";
              }
              return null;
            },
            onChanged: (v) {
              controller.saveModification(ModifyWarningCategory.dateTime);
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
    if (controller.taskReceiveStrategy.value ==
        ReceiveTaskStrategy.freeSelection) {
      widgets.add(_buildTaskReceiversLimitedQuota(context));
    } else {
      widgets.add(_buildTaskReceivers(context));
    }
    widgets.add(_buildTaskCredits(context));
    // return GetBuilder(builder: (controller) => Column(children: widgets));
    return Column(children: widgets);
  }
}
