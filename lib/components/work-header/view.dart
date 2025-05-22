import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../work-task/task-info/controller.dart';
import 'controller.dart';
import 'views/header_crud.dart';
import 'views/select_submit_item.dart';

class PublishSubmitItemsCrudView extends GetView<PublishItemsCrudController> {
  const PublishSubmitItemsCrudView({super.key}); //{
  // Get.put(PublishItemsCrudController());
  // }

  // final bool readOnly;

  @override
  Widget build(BuildContext context) {
    // final cnt = min(3, controller.submitItems.length);
    return Column(
      children: [
        Obx(() => _buildHeaderActions(context)),
        Expanded(
          child: RepaintBoundary(
            child: PublishItemsViewSimpleCrud(
              controller.submitItemAnimatedTreeData,
              controller.readOnly,
              key: controller.itemsSimpleCrudKey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 10,
      children: [
        ElevatedButton(
          onPressed: () {
            controller.expandAll.value = !controller.expandAll.value;
            if (controller.expandAll.value) {
              controller.itemsSimpleCrudKey.currentState?.expandAllChildren();
            } else {
              controller.itemsSimpleCrudKey.currentState?.collapseAllChildren();
            }
          },
          child: Row(
            children: [
              Icon(
                controller.expandAll.value
                    ? Icons.arrow_right_alt_rounded
                    : Icons.arrow_downward,
              ),
              Text(controller.expandAll.value ? "全部折叠" : "全部展开"),
            ],
          ),
        ),
        const Spacer(),
        if (!controller.readOnly) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50, // 背景色
              foregroundColor: Colors.black,
              padding: EdgeInsets.all(4),
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
                            "请选择任务项",
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
                          icon: Text(
                            "确定",
                            style: TextStyle(color: Colors.blue),
                          ),
                          // icon: Text("确定"),
                          onPressed: () {
                            final taskId =
                                controller.taskInfoController.taskId.value;
                            // 先清空旧的
                            controller.itemsSimpleCrudKey.currentState
                                ?.clearAllNodes();
                            // 再设置现在选择的
                            controller.itemsSimpleCrudKey.currentState
                                ?.addNodesToRoot(
                                  controller
                                      .selectHeaderItemsKey
                                      .currentState!
                                      .allCheckedNode,
                                );
                            // 如果存在任务id， 则直接在确定的时候跟它进行绑定
                            if (taskId > Int64.ZERO) {
                              task_api
                                  .bindWorkTaskHeader(
                                    taskId,
                                    Get.find<PublishItemsCrudController>()
                                        .taskHeaderIds,
                                  )
                                  .then((err) {
                                    controller.isSaving.value = false;
                                    if (err == null &&
                                        modalSheetContext.mounted) {
                                      // 如果任务出错，则需要手动关闭咯
                                      Navigator.of(
                                        modalSheetContext,
                                      ).maybePop();
                                    }
                                  });
                            } else {
                              // 此时，就是新建的任务还没有保存，
                              // 需要在保存的时候，跟它进行绑定
                              // 保存变更，以后弹窗提醒
                              controller.taskInfoController.saveModification(
                                ModifyWarningCategory.header,
                              );
                              Navigator.of(modalSheetContext).maybePop();
                            }
                          },
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: GetPlatform.isMobile ? 500 : 800,
                          ),
                          child: Obx(
                            () =>
                                controller.isSaving.value
                                    ? maskingOperation(
                                      context,
                                      _buildSelectSubmitItemView(context),
                                      indicatorType:
                                          Indicator.ballClipRotatePulse,
                                    )
                                    : _buildSelectSubmitItemView(context),
                          ),
                        ),
                      ),
                      // child: ,
                    ],
              );
            },
            child: const Text("选择"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400, // 背景色
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(4),
              // 文字颜色
            ),
            onPressed: () {
              // todo:
              controller.itemsSimpleCrudKey.currentState?.addChildToNode();
            },
            child: const Text("新增"),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectSubmitItemView(BuildContext context) => GetBuilder(
    builder:
        (TaskInfoController ctor) => SelectSubmitItemView(
          ctor.taskId.value,
          key: controller.selectHeaderItemsKey,
        ),
  );
}
