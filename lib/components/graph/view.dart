import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:group_button/group_button.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/vo/room_vo.dart';

import 'controller.dart';
import 'tree_view.dart';

class GraphTaskView extends GetView<GraphTaskController> {
  const GraphTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(controller.graphViewType.value.viewName),
          actions: [_buildChangeViewActionBtn(context)],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: _buildTheGraph(context),
        ),
        // floatingActionButton: GraphTaskCommentView(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildChangeViewActionBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        controller.graphViewType.value = controller.nextViewType;
      },
      child: Row(
        children: [
          Obx(() {
            return Text(controller.nextViewType.viewName);
          }),
          Icon(Icons.swap_horiz),
        ],
      ),
    );
  }

  Widget _buildTheGraph(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          spacing: isBigScreen(context) ? 20.0 : 0.0,
          mainAxisAlignment:
              isBigScreen(context)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
          children: [
            if (controller.graphViewType.value == GraphViewType.organization)
              buildMultiSelectRoomComp(context),
            if (controller.graphViewType.value == GraphViewType.task)
              buildMultiTreeSelectTaskComp(context),
            ElevatedButton(
              onPressed: () async {
                // printInfo(info: controller.selectedTasks.value.join(","));
                // printInfo(info: controller.selectRoomIds.value.join(","));
                //  todo 调用查询接口
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
        Expanded(flex: 1, child: _buildGraphViewWidget(context)),
      ],
    );
    // );
  }

  Widget _buildGraphViewWidget(BuildContext context) {
    return Center(
      child: Obx(
        () => GraphTreeView(
          id: Int64.ZERO,
          graphViewType: controller.graphViewType.value,
        ),
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
