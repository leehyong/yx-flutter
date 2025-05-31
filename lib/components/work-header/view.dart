import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../work-task/task-info/controller.dart';
import 'views/header_crud.dart';
import 'views/select_submit_item.dart';

class PublishSubmitItemsCrudView extends StatefulWidget {
  PublishSubmitItemsCrudView():super(key: Get.find<RootTabController>().publishItemsViewSimpleCrudState);

  @override
  PublishSubmitItemsCrudViewState createState() =>
      PublishSubmitItemsCrudViewState();
}

class PublishSubmitItemsCrudViewState
    extends State<PublishSubmitItemsCrudView> {
  bool isLoadingSubmitItem = false;
  bool expandAll = false;
  final rootSubmitItemAnimatedTreeData = TreeNode<WorkHeader>.root();
  bool isSaving = false;

  TaskInfoController get taskInfoController => Get.find<TaskInfoController>();

  bool get readOnly => taskInfoController.readOnly;

  List<Int64> get taskHeaderIds {
    final headerIds = <Int64>[];
    void headerId(ITreeNode<WorkHeader> node) {
      if (node.key != INode.ROOT_KEY) {
        headerIds.add(node.data!.id);
        return;
      }
      // 把节点id加入结果集中
      for (var child in node.childrenAsList) {
        headerId(child as ITreeNode<WorkHeader>);
      }
    }

    headerId(rootSubmitItemAnimatedTreeData);
    return headerIds;
  }

  @override
  Widget build(BuildContext context) {
    // final cnt = min(3, controller.submitItems.length);
    return Column(
      children: [
         _buildHeaderActions(context),
        Expanded(
          child: RepaintBoundary(
            child: PublishItemsViewSimpleCrud(
              rootSubmitItemAnimatedTreeData,
              readOnly,
            ),
          ),
        ),
      ],
    );
  }

  PublishItemsViewSimpleCrudState? get publishItemsViewSimpleCrudState =>
      Get.find<RootTabController>().publishItemsViewSimpleCrudState.currentState;

  SelectSubmitItemViewState? get selectSubmitItemViewState =>
      Get.find<RootTabController>().selectSubmitItemViewState.currentState;

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 10,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              expandAll = !expandAll;
            });
            if (expandAll) {
              publishItemsViewSimpleCrudState?.expandAllChildren();
            } else {
              publishItemsViewSimpleCrudState?.collapseAllChildren();
            }
          },
          child: Row(
            children: [
              Icon(
                expandAll
                    ? Icons.arrow_right_alt_rounded
                    : Icons.arrow_downward,
              ),
              Text(expandAll ? "全部折叠" : "全部展开"),
            ],
          ),
        ),
        const Spacer(),
        if (!readOnly) ...[
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
                            final taskId = taskInfoController.taskId.value;
                            // 先清空旧的
                            publishItemsViewSimpleCrudState?.clearAllNodes();
                            // 再设置现在选择的
                            publishItemsViewSimpleCrudState?.addNodesToRoot(
                              selectSubmitItemViewState!.allCheckedNode,
                            );
                            // 如果存在任务id， 则直接在确定的时候跟它进行绑定
                            if (taskId > Int64.ZERO) {
                              task_api
                                  .bindWorkTaskHeader(taskId, taskHeaderIds)
                                  .then((err) {
                                    setState(() {
                                      isSaving = false;
                                    });
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
                              taskInfoController.saveModification(
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
                          child:
                              isSaving
                                  ? maskingOperation(
                                    context,
                                    _buildSelectSubmitItemView(context),
                                    indicatorType:
                                        Indicator.ballClipRotatePulse,
                                  )
                                  : _buildSelectSubmitItemView(context),
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
              publishItemsViewSimpleCrudState?.addChildToNode();
            },
            child: const Text("新增"),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectSubmitItemView(BuildContext context) => GetBuilder(
    builder:
        (TaskInfoController ctor) => SelectSubmitItemView(ctor.taskId.value),
  );
}
