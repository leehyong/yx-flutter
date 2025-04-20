import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/toast.dart';

import '../../utils/common_widget.dart';
import 'controller.dart';
import 'header_crud.dart';
import 'header_tree.dart';

class PublishSubmitItemsCrudView extends GetView<PublishItemsCrudController> {
  PublishSubmitItemsCrudView({super.key}) {
    Get.put(PublishItemsCrudController());
  }

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
        Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50, // 背景色
            foregroundColor: Colors.black,
            padding: EdgeInsets.all(4),
            // 文字颜色
          ),
          onPressed: () {
            debugPrint("选择任务项成功");
            controller.itemsSimpleCrudKey.currentState?.addChildToNode();
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
            controller.itemsSimpleCrudKey.currentState?.addChildToNode();

            debugPrint("新增任务项成功");
          },
          child: const Text("新增"),
        ),
      ],
    );
  }
}

// todo: 后续 填报任务项的时候使用它
class PublishItemsViewDetail extends GetView<PublishItemsDetailController> {
  PublishItemsViewDetail({super.key}) {
    Get.put(PublishItemsDetailController());
  }

  Widget _buildRootHeaderNameTable(BuildContext context, WorkHeaderTree root) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(150), // 设置背景色
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Tooltip(
                message: root.task.name,
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      root.task.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            // 阴影颜色
                            offset: Offset(1, 0),
                            // Y 轴偏移量
                            blurRadius: 1, // 阴影模糊程度
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    buildTaskOpenRangeAndContentType(root.task),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // final crossCount = constraints.maxWidth >= 720 ? 4 : 1;
        final cnt = submitItems.length;
        return Obx(
          () => ListView.builder(
            // return GridView.builder(
            shrinkWrap: false,
            reverse: true,
            cacheExtent: 100,
            controller: controller.scrollController,
            // addRepaintBoundaries:t,
            itemCount: controller.isLoadingSubmitItem.value ? cnt + 1 : cnt,
            itemBuilder: (ctx, idx) {
              final headerTree = submitItems[idx];
              final oneItem = [_buildRootHeaderNameTable(context, headerTree)];
              if (headerTree.children.isNotEmpty) {
                oneItem.add(
                  NestedDfsWorkHeaderTreeView(
                    headerTree.task.id.toString(),
                    headerTree.children,
                  ),
                );
              }
              // return Column(children: oneItem);
              return commonCard(Column(children: oneItem), borderRadius: 0);
            },
          ),
        );
      },
    );
  }
}

class NestedDfsWorkHeaderTreeView extends GetView<WorkHeaderController> {
  NestedDfsWorkHeaderTreeView(
    this.rootHeaderTreeId,
    List<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(WorkHeaderController(children), tag: rootHeaderTreeId);
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children:
            controller.children
                .asMap()
                .entries
                .map((e) => _buildHeaderTreeByDfs(context, e.key, 0, e.value))
                .toList(),
      ),
    );
  }

  Widget _buildHeaderTreeByDfs(
    BuildContext context,
    int idx,
    int depth,
    WorkHeaderTree node,
  ) {
    final w;
    if (node.children.isEmpty) {
      // 没有子节点时，独占一行
      w = Row(
        children: [
          Expanded(
            child: NestedDfsWorkHeaderTreeItemView(
              depth,
              node.children,
              task: node.task.obs,
            ),
          ),
        ],
      );
    } else {
      // 否则跟所有子节点一起放在同一行
      // todo 每项的背景色该怎么设置？
      w = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 4,
        children: [
          NestedDfsWorkHeaderTreeItemView(
            depth,
            node.children,
            task: node.task.obs,
          ),
          Expanded(
            child: Column(
              // spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  node.children.asMap().entries.map((e) {
                    return _buildHeaderTreeByDfs(
                      context,
                      e.key,
                      depth + 1,
                      e.value,
                    );
                  }).toList(),
            ),
          ),
        ],
      );
    }

    final colorIdx = (idx + depth) % loadingColors.length;
    // 把颜色做成随机透明的
    final ra = 20 + 230 * Random().nextDouble().toInt();
    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(width: 1.0, color: Colors.black),
        ),
        color: loadingColors[colorIdx].withAlpha(ra),
      ),
      child: w,
    );
  }
}

class NestedDfsWorkHeaderTreeItemView
    extends GetView<OneWorkHeaderItemController> {
  NestedDfsWorkHeaderTreeItemView(
    this.depth,
    List<WorkHeaderTree> children, {
    Rx<WorkHeader>? task,
    super.key,
  }) {
    final _task =
        task ??
        WorkHeader(
          id: Int64(DateTime.now().microsecondsSinceEpoch),
          open: 0,
          contentType: 0,
        ).obs;
    rootHeaderTreeId = _task.value.id.toString();
    Get.put(
      OneWorkHeaderItemController(_task, children),
      tag: rootHeaderTreeId,
    );
  }

  late final String rootHeaderTreeId;
  late final int depth;

  @override
  String get tag => rootHeaderTreeId;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Center(
        child: IconButton(
          onPressed: () {
            if (depth < maxSubmitItemDepth) {
              // addNewHeaderTree(controller.children, "", controller);
              // controller.opsCount.value += 1;
              // controller.update(null, false);
              debugPrint("NestedDfsWorkHeaderTreeItemView add");
            } else {
              errToast("超过最大数量限制");
            }
          },
          highlightColor: Colors.green.withValues(alpha: 0.5),
          icon: Tooltip(
            message: controller.task.value.name,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.task.value.name,
                  overflow: TextOverflow.ellipsis,
                ),
                // Icon(Icons.add, size: 12, color: Colors.black),
                SizedBox(width: 4),
                buildTaskOpenRangeAndContentType(controller.task.value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
