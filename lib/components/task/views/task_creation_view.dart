import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../controllers/task_creation_controller.dart';

class TaskCreationView extends GetView<TaskCreationController> {
  const TaskCreationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新建任务')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 600,  // 最大宽度限制
                  minWidth: 300   // 最小宽度保证可读性
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                  BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  ),
                  ],
                ),
                child: _buildContentColumn(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min, // 关键：使Column根据内容收缩
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(),
        const SizedBox(height: 32),
        _buildStepContent(),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(()=> StepIndicator(currentStep: controller.currentStep.value),),
    );
  }

  Widget _buildStepContent() {
    return Flexible( // 使用Flexible适配剩余空间
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400), // 内容区最大高度
        child: Obx(() {
          switch (controller.currentStep.value) {
            case 1:
              return _buildStep1();
            case 2:
              return _buildStep2();
            case 3:
              return _buildStep3();
            default:
              return Container();
          }
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (controller.currentStep.value > 1)
          ElevatedButton(
            onPressed: controller.previousStep,
            child: const Text('上一步'),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => _handleNextButtonPress(),
          child: Text(controller.currentStep.value == controller.totalSteps
              ? '完成'
              : '下一步'),
        ),
      ],
    ));
  }
  // Step 1 修改部分
  Widget _buildStep1() {
    return Form(
      key: controller.formKeyStep1,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '任务名称'),
              onChanged: controller.dutyName,
              validator: (value) => value?.isEmpty ?? true ? '请输入任务名称' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: ['日常工作', '重点任务', '临时工作']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => controller.dutyType.value = value!,
              decoration: const InputDecoration(labelText: '任务类型'),
              validator: (value) => value == null ? '请选择任务类型' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '细化类型'),
              onChanged: controller.dutyTypeSubTitle,
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    items: controller.departmentNameList
                        .map((e) => DropdownMenuItem(
                        value: e.departmentId,
                        child: Text(e.dutyDepartmentName as String)))
                        .toList(),
                    onChanged: (value) {
                      controller.responsibleDepartmentId.value = value!;
                      controller.isStep3Initialized.value = false;
                    },
                    decoration: const InputDecoration(labelText: '责任科室（主办）'),
                    validator: (value) => value == null ? '请选择主办科室' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    items: controller.departmentNameList
                        .map((e) => DropdownMenuItem(
                        value: e.departmentId,
                        child: Text(e.dutyDepartmentName as String)))
                        .toList(),
                    onChanged: (value) {
                      controller.collaborativeDepartmentId.value = value!;
                      controller.isStep3Initialized.value = false;
                    },
                    decoration: const InputDecoration(labelText: '责任科室（协办）'),
                  ),
                ),
              ],
            ),
            Row(
                children: [
                  const Text('重要程度:', style: TextStyle(fontSize: 16)),
                  Expanded( // 添加 Expanded 提供弹性约束
                    child: _buildImportanceLevelSelector(),
                  ),
                ]
            )
          ],
        ),
      ),
    );
  }
// Step 2
  Widget _buildStep2() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 1),
            );
            if (date != null) {
              // 将日期转换为 yyyy-MM-dd 格式
              final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              controller.dutyEndDate.value = formattedDate;
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: '完成时限'),
            child: Text(controller.dutyEndDate.value?.toString() ?? '选择日期'),
          ),
        ),
        Row(
            children: [
              const Text('进度考核:', style: TextStyle(fontSize: 16)),
              Expanded(child:         RadioListTile<String>(
                title: const Text('百分比'),
                value: '2',
                groupValue: controller.processAssessmentMethod.value,
                onChanged: (value) => controller.processAssessmentMethod.value = value!,
              )
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('是否完成'),
                  value: '1',
                  groupValue: controller.processAssessmentMethod.value,
                  onChanged: (value) => controller.processAssessmentMethod.value = value!,
                ),
              ),
            ]
        ),
        Row(
            children: [
              const Text('是否可以延期:', style: TextStyle(fontSize: 16)),
              Expanded(child:         RadioListTile<String>(
                title: const Text('是'),
                value: '1',
                groupValue: controller.responsibleIfPostpone.value,
                onChanged: (value) => controller.responsibleIfPostpone.value = value!,
                )
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('否'),
                  value: '0',
                  groupValue: controller.responsibleIfPostpone.value,
                  onChanged: (value) => controller.responsibleIfPostpone.value = value!,
                ),
              ),
            ]
        ),
        Row(
          children: [
            const Text('紧急程度:', style: TextStyle(fontSize: 16)),
            Expanded( // 添加 Expanded 提供弹性约束
              child: _buildUrgencyLevelSelector(),// )
            ),
          ]
        ),

        // const SizedBox(height: 16),
        Row(
          children: [
            const Text('管控方式:', style: TextStyle(fontSize: 16)),
            ...['按日', '按周', '按月'].map((method) => Expanded(child:RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: controller.selectedControlMethod.value,
              onChanged: (value) => controller.selectedControlMethod.value = value!,
            ) )),
          ]
        ),
      ],
    );
  }

// Step 3
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 固定标题
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '请选择任务分配对象',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 内容区域
          Expanded(
            child: Obx(() => !controller.isStep3Initialized.value
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                // 表头（使用相同列宽约束）
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child:Center(
                            child: Text('用户名字', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 1,
                          child: Center(child: Text('任务负责人')),
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 1,
                          child: Center(child: Text('一般参与者')),
                        ),
                      ],
                    ),
                  ),
                ),
                // 列表内容
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.assigneeList.length,
                    itemBuilder: (context, index) {
                      final user = controller.assigneeList[index];
                      return IntrinsicWidth(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 用户名（允许换行）
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                  user['data']['userRealName'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  ),
                                ),
                              ),
                              // 间隔
                              const Spacer(flex: 1),
                              // 负责人复选框
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Obx(
                                        () => Checkbox(
                                      value: user['isLeader'].value,
                                      onChanged: (bool? value) {
                                        controller.toggleSelection(index, true);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex: 1),
                              // 参与者复选框
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Obx(
                                        () => Checkbox(
                                      value: user['isParticipant'].value,
                                      onChanged: (bool? value) {
                                        controller.toggleSelection(index, false);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
          ),
          // 确认按钮
          Obx(() => controller.isStep3Initialized.value
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('确认分配并返回'),
              onPressed: controller.completeTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _handleNextButtonPress() {
    final currentStep = controller.currentStep.value;
    bool isValid = true;

    // 步骤验证
    if (currentStep == 1) {
      isValid = _validateStep1();
    } else if (currentStep == 2) {
      isValid = _validateStep2();
    } else if (currentStep == 3) {
      isValid = _validateStep3();
    }

    if (isValid) {
      if (currentStep == controller.totalSteps) {
        controller.completeTask();
      } else {
        controller.nextStep();
      }
    }
  }

  bool _validateStep1() {
    // 表单字段验证
    final formValid = controller.formKeyStep1.currentState?.validate() ?? false;

    // 科室重复验证
    final deptValid = controller.responsibleDepartmentId.value !=
        controller.collaborativeDepartmentId.value;

    if (!deptValid) {
      toastification.show(
        type: ToastificationType.error,
        title: Text("主办科室和协办科室不能相同"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }

    return formValid && deptValid;
  }

  bool _validateStep2() {
    //暂时没有需要添加的检查
    return true;
  }

  bool _validateStep3() {
    final hasLeader = controller.assigneeList.any((user) => user['isLeader'].value);

    if (!hasLeader) {
      toastification.show(
        type: ToastificationType.error,
        title: Text("至少需要选择一名任务负责人"),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return false;
    }
    return true;
  }


  Widget _buildImportanceLevelSelector() {
    return Obx(() => _buildRadioGroup(
      groupValue: controller.dutyImportance.value,
      onChanged: (value) => controller.dutyImportance.value = value,
      options: const [
        RadioOption(label: '一般', value: '一般'),
        RadioOption(label: '重要', value: '重要'),
        RadioOption(label: '特别重要', value: '特别重要'),
      ],
    ));
  }
  Widget _buildUrgencyLevelSelector() {
    return Obx(() => _buildRadioGroup(
      groupValue: controller.dutyUrgency.value,
      onChanged: (value) => controller.dutyUrgency.value = value,
      options: const [
        RadioOption(label: '一般', value: '一般'),
        RadioOption(label: '普通', value: '普通'),
        RadioOption(label: '紧急', value: '紧急'),
      ],
    ));
  }

}


class StepIndicator extends GetView<TaskCreationController> {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [1, 2, 3].map((step) {
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;

        return Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent ? Colors.blue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: isCompleted || isCurrent ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '任务阶段$step',
              style: TextStyle(
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                color: isCompleted || isCurrent ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// 修改后的通用Radio组构建器
Widget _buildRadioGroup({
  required String groupValue,
  required Function(String) onChanged,
  required List<RadioOption> options,
}) {
  return SingleChildScrollView( // 添加横向滚动防止溢出
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisSize: MainAxisSize.min, // 紧凑排列
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(right: 16), // 按钮间距
          child: _buildCompactRadioButton( // 使用紧凑版按钮
            label: option.label,
            value: option.value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        );
      }).toList(),
    ),
  );
}

// 紧凑型Radio按钮构建器
Widget _buildCompactRadioButton({
  required String label,
  required String value,
  required String groupValue,
  required Function(String) onChanged,
}) {
  return MergeSemantics( // 合并语义节点
    child: GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 紧凑布局
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) => onChanged(v!),
          ),
          Text(label), // 直接显示文本
        ],
      ),
    ),
  );
}

// Radio选项数据模型
class RadioOption {
  final String label;
  final String value;

  const RadioOption({
    required this.label,
    required this.value,
  });
}