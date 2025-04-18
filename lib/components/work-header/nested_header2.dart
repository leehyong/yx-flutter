import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/toast.dart';

import '../../utils/common_widget.dart';
import 'controller.dart';
import 'header_tree.dart';

class PublishItemsView extends GetView<PublishItemsController> {
  PublishItemsView({super.key}) {
    Get.put(PublishItemsController());
  }

  Widget _buildRootHeaderNameTable(BuildContext context, WorkHeaderTree root) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue, // 设置背景色
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Obx(
                () => Tooltip(
                  message: root.task.value.name,
                  child: Row(
                    spacing: 8,
                    children: [
                      Text(
                        root.task.value.name,
                        style: TextStyle(
                          fontSize: 22,
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
                      buildTaskOpenRangeAndContentType(root.task.value),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 背景色
              foregroundColor: Colors.black,
              padding: EdgeInsets.only(left: 4, right: 4),
              // 文字颜色
            ),
            onPressed: () {
              addNewHeaderTree(root.children, "", controller);
              debugPrint("新增子节点成功");
              // root.children.value.add(
              //   newEmptyHeaderTree("${DateTime.now().millisecondsSinceEpoch}"),
              // );
            },
            child: Row(
              children: [
                Text(
                  "新增子项",
                  // style: TextStyle(fontSize: 16, color: Colors.yellow),
                ),
                const SizedBox(width: 4),
                // Icon(Icons.add, size: 20, color: Colors.yellow),
                Icon(Icons.add, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final cnt = min(3, controller.submitItems.length);
    final cnt = controller.submitItems.length;
    return Column(
      children: [
        Row(
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
                debugPrint("选择任务项成功");
              },
              child: const Text("选择"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50, // 背景色
                foregroundColor: Colors.black,
                padding: EdgeInsets.all(4),
                // 文字颜色
              ),
              onPressed: () {
                debugPrint("新增任务项成功");
                addNewHeaderTree(
                  controller.submitItems,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  controller,
                  needJump: true
                );
              },
              child: const Text("新增"),
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final crossCount = constraints.maxWidth >= 720 ? 4 : 1;
              return Obx(
                () => ListView.builder(
                  // return GridView.builder(
                  shrinkWrap: false,
                  reverse: true,
                  cacheExtent:100,
                  controller: controller.scrollController,
                  // addRepaintBoundaries:t,
                  itemCount:
                      controller.isLoadingSubmitItem.value ? cnt + 1 : cnt,
                  itemBuilder: (ctx, idx) {
                    final headerTree = controller.submitItems.value[idx];
                    final oneItem = [
                      _buildRootHeaderNameTable(context, headerTree.value),
                    ];
                    if (headerTree.value.children.isNotEmpty) {
                      oneItem.add(
                        Obx(
                          () => NestedDfsWorkHeaderTreeView(
                            headerTree.value.task.value.id.toString(),
                            headerTree.value.children,
                          ),
                        ),
                      );
                    }
                    // return Column(children: oneItem);
                    return commonCard(
                      Column(children: oneItem),
                      borderRadius: 0,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NestedDfsWorkHeaderTreeView extends GetView<WorkHeaderController> {
  NestedDfsWorkHeaderTreeView(
    this.rootHeaderTreeId,
    RxList<Rx<WorkHeaderTree>> children, {
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
    Rx<WorkHeaderTree> node,
  ) {
    final w;
    if (node.value.children.isEmpty) {
      // 没有子节点时，独占一行
      w = Row(
        children: [
          Expanded(
            child: NestedDfsWorkHeaderTreeItemView(
              depth,
              node.value.children,
              task: node.value.task,
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
            node.value.children,
            task: node.value.task,
          ),
          Expanded(
            child: Column(
              // spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  node.value.children.asMap().entries.map((e) {
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
    RxList<Rx<WorkHeaderTree>> children, {
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
            if (depth < maxSubmitItemDepthExclusive) {
              addNewHeaderTree(controller.children, "", controller);
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
                Icon(Icons.add, size: 12, color: Colors.black),
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
