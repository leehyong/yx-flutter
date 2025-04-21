import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../../work-header/nested_header2.dart';
import '../task-list/view.dart';
import 'controller.dart';

class TaskInfoView extends StatelessWidget {
  TaskInfoView({
    super.key,
    // required this.taskCategory,
    required this.publishTaskParams,
  }) {
    var _title = TaskOperationCategory.detailTask;
    if (publishTaskParams.opCat == null) {
      if (publishTaskParams.routeId == NestedNavigatorKeyId.hallId) {
        if (publishTaskParams.task == null || publishTaskParams.task!.id == 0) {
          _title = TaskOperationCategory.publishTask;
        }
      } else if (publishTaskParams.routeId == NestedNavigatorKeyId.myTaskId) {
        // 我的任务那里的话就是填报任务了，此时 task 肯定满足以下条件
        assert(publishTaskParams.task != null);
        assert(publishTaskParams.task!.id > 0);
        _title = TaskOperationCategory.submitTask;
      }
    } else {
      _title = publishTaskParams.opCat!;
    }
    title = _title;
  }

  final HallPublishTaskParams publishTaskParams;

  // final int parentId;
  // final WorkTask? task;
  // final TaskListCategory taskCategory;
  // final int routeId;
  late final TaskOperationCategory title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.i18name, style: defaultTitleStyle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _buildBodyView(context),
      ),
    );
  }

  Widget _buildBodyView(BuildContext context) {
    switch (title) {
      case TaskOperationCategory.detailTask:
        return _PublishTaskView(
          publishTaskParams.parentId,
          publishTaskParams.task!.id,
          true,
        );
      case TaskOperationCategory.publishTask:
        return _PublishTaskView(Int64.ZERO, Int64.ZERO);
      case TaskOperationCategory.updateTask:
        return _PublishTaskView(
          publishTaskParams.parentId,
          publishTaskParams.task!.id,
        );
      case TaskOperationCategory.submitTask:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class _PublishTaskView extends GetView<PublishTaskController> {
  _PublishTaskView(Int64 parentId, Int64 taskId, [this.readOnly = false]) {
    Get.put(PublishTaskController(parentId, taskId));
  }

  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Form(
        key: controller.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRelationAttributes(context),
            Expanded(child: _buildTaskRelates(context)),
            if (!readOnly)
              maybeOneThirdCenterHorizontal(_buildActions(context)),
          ],
        ),
      );
    });
  }

  Widget _buildRelationAttributes(BuildContext context) {
    return SegmentedButton(
      segments:
          TaskAttributeCategory.values
              .map((e) => ButtonSegment(value: e, label: Text(e.i18name)))
              .toList(),
      onSelectionChanged: (s) {
        debugPrint(s.toString());
        controller.selectedAttrSet.value = s;
      },
      selected: controller.selectedAttrSet.value,
      multiSelectionEnabled: false,
    );
  }

  Widget _buildTaskRelates(BuildContext context) {
    switch (controller.selectedAttrSet.first) {
      case TaskAttributeCategory.basic:
        return maybeOneThirdCenterHorizontal(
          _publishTaskBasicInfoView(context),
        );
      case TaskAttributeCategory.submitItem:
        return PublishSubmitItemsCrudView(Int64.ZERO);

      case TaskAttributeCategory.parentTask:
        return _publishTaskParentInfoView(context);
      case TaskAttributeCategory.childrenTask:
        return _publishTaskChildrenInfoView(context);
    }
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
          },
          child: const Text("草稿"),
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
          },
          child: const Text("发布"),
        ),
      ],
    );
  }

  Widget _publishTaskParentInfoView(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50, // 背景色
              foregroundColor: Colors.black,
              padding: EdgeInsets.all(4),
              // 文字颜色
            ),
            onPressed: () {
              debugPrint("选择父任务成功");
            },
            child: const Text("选择"),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TaskListView(
                tasks: [controller.parentTask.value],
                taskCategory: TaskListCategory.parentTaskInfo,
                routeId: NestedNavigatorKeyId.hallId,
                isLoading: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [const Text("删除"), const Text("修改")],
    );
  }

  Widget _publishTaskChildrenInfoView(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50, // 背景色
              foregroundColor: Colors.black,
              padding: EdgeInsets.all(4),
              // 文字颜色
            ),
            onPressed: () {
              debugPrint("选择子任务成功");
            },
            child: const Text("选择"),
          ),
        ),
        Expanded(
          child: TaskListView(
            tasks: controller.childrenTask.value,
            taskCategory: TaskListCategory.childrenTaskInfo,
            routeId: NestedNavigatorKeyId.hallId,
            isLoading: false,
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
      controller: controller.taskNameController,
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
      controller: controller.taskContentController,
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
            controller: controller.taskContactorController,
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
            controller: controller.taskContactPhoneController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '联系电话',
              icon: Icon(Icons.phone_android),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSubmitCycleCredits(BuildContext context) {
    return DropdownButtonFormField(
      value: controller.taskSubmitCycleStrategy.value,
      decoration: InputDecoration(
        enabled: !readOnly,
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
        controller.taskSubmitCycleStrategy.value = v!;
      },
    );
  }

  Widget _buildTaskCredits(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: controller.taskCreditStrategy.value,
            decoration: InputDecoration(
              labelText: '积分方式',
              enabled: !readOnly,
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
              controller.taskCreditStrategy.value = v!;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            keyboardType: TextInputType.numberWithOptions(),
            controller: controller.taskCreditsController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '任务积分',
              icon: Icon(Icons.diamond_outlined),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
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
      controller: controller.taskReceiverQuotaLimitedController,
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
            if (readOnly) {
              return;
            }
            //   todo  增加选择人员的功能
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
          child: DropdownButtonFormField(
            value: controller.taskReceiveStrategy.value,
            decoration: InputDecoration(
              labelText: '领取方式',
              enabled: !readOnly,
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
              controller.taskReceiveStrategy.value = v!;
            },
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
                controller.taskReceiveDeadlineController.text,
              );
              DateTime date = await showCusDateTimePicker(context, dt: dt);
              controller.taskReceiveDeadlineController.text = defaultDtFormat1
                  .format(date);
              // debugPrint("selectdt${date.toIso8601String()}");
            },
            controller: controller.taskReceiveDeadlineController,
            decoration: InputDecoration(
              enabled: !readOnly,
              labelText: '领取截止时间',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
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
              final dt = parseDateFromStr(
                controller.taskPlanStartDtController.text,
              );
              DateTime date = await showCusDatePicker(context, dt: dt);
              controller.taskPlanStartDtController.text = defaultDateFormat
                  .format(date);
            },
            keyboardType: TextInputType.datetime,
            controller: controller.taskPlanStartDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !readOnly,
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
          ),
        ),
        Expanded(
          child: TextFormField(
            readOnly: readOnly,
            onTap: () async {
              if (readOnly) {
                return;
              }
              final dt = parseDateFromStr(
                controller.taskPlanEndDtController.text,
              );
              DateTime date = await showCusDatePicker(context, dt: dt);
              controller.taskPlanEndDtController.text = defaultDateFormat
                  .format(date);
            },

            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: controller.taskPlanEndDtController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              enabled: !readOnly,
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
          ),
        ),
      ],
    );
  }

  Widget _publishTaskBasicInfoView(BuildContext context) {
    final widgets = [
      _buildTaskName(context),
      _buildTaskContent(context),
      _buildTaskSubmitCycleCredits(context),
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
