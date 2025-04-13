import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';

import 'controller.dart';

class TaskInfoView extends StatelessWidget {
  TaskInfoView({
    super.key,
    // required this.taskCategory,
    required this.publishTaskParams,
  }) {
    var _title = TaskOperationCategory.detailTask;
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
        // TODO: Handle this case.
        throw UnimplementedError();
      case TaskOperationCategory.publishTask:
        // TODO: Handle this case.
        return _PublishTaskView(publishTaskParams.parentId);
      case TaskOperationCategory.submitTask:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}


class _PublishTaskView extends GetView<PublishTaskController> {
  _PublishTaskView(this.parentId) {
    Get.put(PublishTaskController());
  }

  final int parentId;

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
            _buildActions(context),
          ],
        ),
      );
      // return ConstrainedBox(
      //   constraints: BoxConstraints.expand(),
      //   child: Form(
      //     key: controller.formKey,
      //     autovalidateMode: AutovalidateMode.onUserInteraction,
      //     child: Column(
      //       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: children,
      //     ),
      //   ),
      // );
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
        return _publishTaskBasicInfoView(context);
      case TaskAttributeCategory.parentTask:
        return _publishTaskParentInfoView(context);
      case TaskAttributeCategory.submitItem:
        return _publishTaskSubmitItemView(context);
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

  Widget _buildOneTaskProfileInfo(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      // 设置卡片的阴影高度
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Colors.blue.shade300, width: 1.0),
      ),
      child: Column(
        children: [
          Text(
            "112233",
            style: TextStyle(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "31312444",
            style: TextStyle(fontSize: 12),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _publishTaskParentInfoView(BuildContext context){
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
            child: const Text("请选择父任务"),
          ),
        ),
        _buildOneTaskProfileInfo(context),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [const Text("删除"), const Text("修改")],
    );
  }
  Widget _publishTaskChildrenInfoView(BuildContext context){
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
            child: const Text("请选择子任务"),
          ),
        ),
        SingleChildScrollView(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, idx) {
              return _buildOneTaskProfileInfo(context);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _publishTaskSubmitItemView(BuildContext context){
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
              debugPrint("选择任务项成功");
            },
            child: const Text("请选择任务项"),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, idx) {
                return Text("data $idx");
              },
            ),
          ),
        ),
        Table(
          border: TableBorder.all(color: Colors.grey), // 边框样式
          columnWidths: {
            0: FixedColumnWidth(140), // 第一列固定宽度
            1: FixedColumnWidth(60), // 第一列固定宽度
            2: FlexColumnWidth(), // 第二列自适应
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle, // 垂直居中
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.blue[100]),
              children: [Text("名称"), Text("类型"), Text("操作")],
            ),
            TableRow(
              children: [Text("张三"), Text("数字"), _buildHeaderActions(context)],
            ),
            TableRow(
              children: [Text("莉丝"), Text("文本"), _buildHeaderActions(context)],
            ),
            TableRow(
              children: [Text("王五"), Text("小数"), _buildHeaderActions(context)],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskName(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: true,
      maxLines: 1,
      controller: controller.taskNameController,
      decoration: const InputDecoration(
        labelText: '名称',
        icon: Icon(Icons.table_bar),
      ),
      validator: (v) {
        // todo 查询数据库看看名称是否重复了
        return null;
      },
    );
  }

  Widget _buildTaskContent(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: true,
      minLines: 3,
      maxLines: 5,
      // 固定显示 5 行
      expands: false,
      // 禁止无限扩展
      controller: controller.taskContentController,
      decoration: const InputDecoration(
        labelText: '内容',
        icon: Icon(Icons.text_snippet_outlined),
      ),
      validator: (v) {
        // 暂不需要验证
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
            decoration: const InputDecoration(
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
            decoration: const InputDecoration(
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

  Widget _buildTaskCredits(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: controller.taskCreditStrategy.value,
            decoration: const InputDecoration(
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
              controller.taskCreditStrategy.value = v!;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(),
            controller: controller.taskCreditsController,
            decoration: const InputDecoration(
              labelText: '任务积分',
              icon: Icon(Icons.diamond),
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
      keyboardType: TextInputType.numberWithOptions(),
      controller: controller.taskReceiverQuotaLimitedController,
      decoration: const InputDecoration(
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
      children.add(
        Text(
          controller.selectedPersons.value.first,
          style: TextStyle(color: Colors.purpleAccent),
        ),
      );
      if (controller.selectedPersons.value.length > 1) {
        children.addAll([
          const Text("等"),
          Text(
            controller.selectedPersons.value.length.toString(),
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          const Text("人"),
        ]);
      }
    }
    return Row(
      children: [
        IconButton(
          onPressed: () {
            debugPrint("选择人员");
          },
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              spacing: 4,
              children: [
                const Text("选择人员", style: TextStyle(color: Colors.white)),
                Icon(Icons.people, color: Colors.white),
              ],
            ),
          ),
        ),
        if (children.isNotEmpty) Expanded(child: Row(children: children)),
      ],
    );
  }

  Widget _buildReceiveTask(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: controller.taskReceiveStrategy.value,
            decoration: const InputDecoration(
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
              controller.taskReceiveStrategy.value = v!;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: controller.taskReceiveDeadlineController,
            decoration: const InputDecoration(
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
            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: controller.taskPlanStartDtController,
            decoration: const InputDecoration(
              labelText: '开始时间',
              icon: Icon(Icons.access_alarm),
            ),
            validator: (v) {
              // 暂不需要验证
              return null;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.datetime,
            // 固定显示 5 行
            // 禁止无限扩展
            controller: controller.taskPlanEndDtController,
            decoration: const InputDecoration(
              labelText: '结束时间',
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
  Widget _publishTaskBasicInfoView(BuildContext context){
    final widgets = [
      _buildTaskName(context),
      _buildTaskContent(context),
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
