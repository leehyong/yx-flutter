import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:graphview/GraphView.dart';
import 'package:group_button/group_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:single_child_two_dimensional_scroll_view/single_child_two_dimensional_scroll_view.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yx/config.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';
import 'package:yx/vo/graph_vo.dart' as graph_vo;
import 'package:yx/vo/room_vo.dart';

import 'controller.dart';
import 'graph-comment/controller.dart';
import 'graph-comment/view.dart';

class GraphTaskView extends GetView<GraphTaskController> {
  const GraphTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: Text("任务视图")),
        body: Container(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 16),
          child:
              GetPlatform.isMobile ? buildMobile(context) : buildWeb(context),
        ),
        // floatingActionButton: GraphTaskCommentView(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget buildWeb(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: [
            buildMultiSelectRoomComp(context),
            buildMultiTreeSelectTaskComp(context),
            ElevatedButton(
              onPressed: () async {
                // printInfo(info: controller.selectedTasks.value.join(","));
                // printInfo(info: controller.selectRoomIds.value.join(","));
                //  调用查询接口
                await controller.setGraphViewData();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "查询",
                    style: TextStyle(color: controller.selectedObjColor),
                  ),
                  Icon(Icons.search, color: controller.selectedObjColor),
                ],
              ),
            ),
          ],
        ),
        // 绘制任务视图
        Expanded(flex: 1, child: Center(child: buildGraphViewWidget(context))),
      ],
    );
  }

  Widget buildMobile(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildMultiSelectRoomComp(context),
            buildMultiTreeSelectTaskComp(context),
            ElevatedButton(
              onPressed: () async {
                // printInfo(info: controller.selectedTasks.value.join(","));
                // printInfo(info: controller.selectRoomIds.value.join(","));
                //  调用查询接口
                await controller.setGraphViewData();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("查询"), Icon(Icons.search, color: Colors.blue)],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        // 绘制任务视图
        Expanded(flex: 1, child: Center(child: buildGraphViewWidget(context))),
      ],
    );
    // );
  }

  Widget buildGraphViewWidget(BuildContext context) {
    var nodes = controller.graphVoData.value?.nodes;
    if (nodes == null || nodes.isEmpty) {
      switch (controller.loadingData.value) {
        case DataLoadingStatus.loading:
          return SizedBox(
            width: 200,
            height: 200,
            child: LoadingIndicator(
              indicatorType: Indicator.ballClipRotatePulse,

              /// Required, The loading type of the widget
              colors: loadingColors,

              strokeWidth: 3,
            ),
          );
        case DataLoadingStatus.loaded:
          return emptyWidget(context);
        default:
          return SizedBox.shrink();
      }
    }

    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 3.0,
      child: Scrollbar(
        controller: controller.verticalScrollController,
        child: Scrollbar(
          controller: controller.horintalScrollController,
          child: SingleChildTwoDimensionalScrollView(
            verticalController: controller.verticalScrollController,
            horizontalController: controller.horintalScrollController,
            child: Center(
              child: GraphView(
                graph: controller.graph.value!,
                algorithm: BuchheimWalkerAlgorithm(
                  controller.graphBuilder,
                  TreeEdgeRenderer(controller.graphBuilder),
                ),
                paint:
                    Paint()
                      ..color = Colors.green
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  // I can decide what widget should be shown here based on the id
                  var k = node.key!.value as String;
                  var nodes = controller.graphVoData.value!.nodes!;
                  var nodeValue = nodes[k];
                  return rectangleWidget(context, k, nodeValue);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rectangleWidget(BuildContext cxt, String k, graph_vo.Node? node) {
    var a = node?.label ?? "default";
    a = '$a-$k';
    return InkWell(
      onTap: () async {
        // 点击任务时才会展示任务评价
        if (node != null && node.type == 'duty') {
          // 打开任务评价页面 并且设置当前任务节点
          controller.curTaskNode.value = node;
          controller.curTaskId.value = k;
          // controller.curTaskNode.value = graph_vo.Node(label: "lhytets", children: [],);
          GraphTaskCommentController.instance.curTaskNode.value =
              controller.curTaskNode.value;
          GraphTaskCommentController.instance.curTaskId.value = k;
          GraphTaskCommentController.instance.curCommentVo.value = null;
          // 等待获取数据完成
          await GraphTaskCommentController.instance.fetchInitData();
          if (cxt.mounted) {
            await WoltModalSheet.show(
              useSafeArea: true,
              context: cxt,
              showDragHandle: GetPlatform.isMobile,
              enableDrag: GetPlatform.isMobile,
              onModalDismissedWithBarrierTap: () async {
                // 避免快速点击
                if (GraphTaskCommentController.instance.loading.value) {
                  errIsLoadingData();
                } else {
                  await GraphTaskCommentController.instance
                      .closeOrRemoveOnePopupLayer(cxt);
                }
              },
              onModalDismissedWithDrag: ()async{
                if (GraphTaskCommentController.instance.loading.value) {
                  errIsLoadingData();
                } else {
                  await GraphTaskCommentController.instance
                      .closeOrRemoveOnePopupLayer(cxt);
                }
              },
              modalTypeBuilder: (BuildContext context) {
                final width = MediaQuery.sizeOf(context).width;
                if (width < 600) {
                  return WoltModalType.bottomSheet();
                } else if (width < 800) {
                  return WoltModalType.dialog();
                } else {
                  return WoltModalType.sideSheet();
                }
              },
              pageListBuilder:
                  (modalSheetContext) => [
                    WoltModalSheetPage(
                      topBarTitle: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("任务："),
                            Text(
                              node.label.length > 5
                                  ? node.label.substring(0, 5)
                                  : node.label,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.red, // 下划线颜色（可选）
                              ),
                            ),
                            Text("的评价"),
                          ],
                        ),
                      ),
                      hasTopBarLayer: true,
                      // hasSabGradient: false,
                      isTopBarLayerAlwaysVisible: true,
                      child: GraphTaskCommentView(),
                    ),

                    WoltModalSheetPage(
                      topBarTitle: Center(
                        child: Obx(
                          () => Text(
                            GraphTaskCommentController
                                .instance
                                .editCompSheetPageTitle,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      hasTopBarLayer: true,
                      // hasSabGradient: false,
                      isTopBarLayerAlwaysVisible: true,
                      leadingNavBarWidget: IconButton(
                        padding: const EdgeInsets.all(4),
                        icon: const Text("返回"),
                        // icon: Text("取消"),
                        onPressed: () {
                          WoltModalSheet.of(modalSheetContext).showAtIndex(0);
                          // Navigator.pop(modalSheetContext);
                          // controller.closeOrRemoveOnePopupLayer(modalSheetContext);
                        },
                      ),
                      trailingNavBarWidget: IconButton(
                        padding: const EdgeInsets.all(4),
                        icon: const Text(
                          "关闭",
                          style: TextStyle(color: Colors.blue),
                        ),
                        // icon: Text("确定"),
                        onPressed:
                            () => GraphTaskCommentController.instance
                                .closeTheEntirePopupLayer(modalSheetContext),
                      ),
                      child: GraphEditTaskCommentView(),
                    ),
                  ],
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: getNodeBgColor(node?.type),
        ),
        child: Text(a),
      ),
    );
  }

  Widget buildMultiSelectRoomComp(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        WoltModalSheet.show(
          onModalDismissedWithBarrierTap: () {
            Navigator.of(context).maybePop();
          },
          useSafeArea: true,
          context: context,
          modalTypeBuilder: (BuildContext context) {
            final width = MediaQuery.sizeOf(context).width;
            if (width < 600) {
              return const WoltBottomSheetType(showDragHandle: false);
            } else if (width < 800) {
              return WoltModalType.dialog();
            } else {
              return WoltModalType.sideSheet();
            }
          },
          pageListBuilder:
              (modalSheetContext) => [
                WoltModalSheetPage(
                  topBarTitle: Center(
                    child: Text(
                      "请选择科室",
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
                      // 点击重置按钮会清空已选择的数据
                      controller.roomVoController.selectedIndexes.clear();
                      controller.selectedRoomOneValue.value = '';
                      Navigator.of(modalSheetContext).pop();
                    },
                  ),
                  trailingNavBarWidget: IconButton(
                    padding: const EdgeInsets.all(4),
                    icon: Text("确定", style: TextStyle(color: Colors.blue)),
                    // icon: Text("确定"),
                    onPressed: () {
                      // controller.selectedTreeNodes.value = controller.treeViewTaskKey.currentState?.getSelectedNodes() ?? [];
                      Navigator.of(modalSheetContext).maybePop();
                    },
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 80,
                      maxHeight: GetPlatform.isMobile ? 500 : 800,
                    ),
                    child: Center(
                      child: _multiRoomSelectSelectBox(modalSheetContext),
                    ),
                  ),
                ),
                // child: ,
              ],
        );
      },
      child: Row(
        spacing: 2,
        children:
            controller.selectedRoomOneValue.value.isEmpty
                ? [Text("科室?"), Icon(Icons.home, color: Colors.blue)]
                : [
                  Text("科室:"),
                  Text(
                    controller.selectedRoomOneValue.value,
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
      ),
    );
  }

  Widget buildMultiTreeSelectTaskComp(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        WoltModalSheet.show(
          onModalDismissedWithBarrierTap: () {
            Navigator.of(context).maybePop();
          },
          useSafeArea: true,
          context: context,
          modalTypeBuilder: (BuildContext context) {
            final width = MediaQuery.sizeOf(context).width;
            if (width < 600) {
              return const WoltBottomSheetType(showDragHandle: false);
            } else if (width < 800) {
              return WoltModalType.dialog();
            } else {
              return WoltModalType.sideSheet();
            }
          },
          pageListBuilder:
              (modalSheetContext) => [
                WoltModalSheetPage(
                  topBarTitle: Center(
                    child: Text(
                      "请选择任务",
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
                      controller.selectedTasks.value = {};
                      // 点击重置按钮会清空已选择的数据
                      controller.selectedTaskOneValue.value = '';
                      controller.maxTaskDepth.value = 1;
                      Navigator.of(modalSheetContext).pop();
                    },
                  ),
                  trailingNavBarWidget: IconButton(
                    padding: const EdgeInsets.all(4),
                    icon: Text("确定", style: TextStyle(color: Colors.blue)),
                    // icon: Text("确定"),
                    onPressed: () {
                      Navigator.of(modalSheetContext).maybePop();
                    },
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: GetPlatform.isMobile ? 500 : 800,
                    ),
                    child: _taskSelectTree(modalSheetContext),
                  ),
                ),
                // child: ,
              ],
        );
      },
      child: Row(
        spacing: 2,
        children:
            controller.selectedTaskOneValue.value.isEmpty
                ? [Text("任务?"), Icon(Icons.task, color: Colors.blue)]
                : [
                  Text("任务:"),
                  Text(
                    controller.selectedTaskOneValue.value,
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
      ),
    );
  }

  Widget _taskSelectTree(BuildContext cxt) {
    return SizedBox.shrink();
  }

  Widget _multiRoomSelectSelectBox(BuildContext cxt) {
    return GroupButton<RoomVo>(
      isRadio: false,
      controller: controller.roomVoController,
      buttons: controller.allRooms.value,
      buttonTextBuilder: (selected, room, context) => room.dutyDepartmentName!,
      onSelected: (data, idx, checked) {
        controller.setSelectedRoomsData();
      },
    );
  }
}
