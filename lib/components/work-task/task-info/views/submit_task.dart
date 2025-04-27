import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import '../../../work-header/controller.dart';
import '../../../work-header/data.dart';
import '../controller.dart';

// 填报任务项的时候使用它
class SubmitTasksView extends GetView<SubmitTasksController> {
  SubmitTasksView({super.key}) {
    Get.put(SubmitTasksController());
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
                .map(
                  (e) => _buildHeaderTreeByDfs(context, e.key, 0, "", e.value),
                )
                .toList(),
      ),
    );
  }

  Widget _buildHeaderTreeByDfs(
    BuildContext context,
    int idx,
    int depth,
    String parentHeaderName,
    WorkHeaderTree node,
  ) {
    final w;
    if (node.children.isEmpty) {
      // 没有子节点时，独占一行
      return Column(
        children: [
          Row(
            children: [
              Text("*"), // 是否必填
              Text(
                node.task.name,
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          TextField(
            textInputAction: TextInputAction.send,
            autofocus: true,
            maxLines: 4,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
          ),
        ],
      );
    } else {
      w = Column(
        // spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            node.children.asMap().entries.map((e) {
              return _buildHeaderTreeByDfs(
                context,
                e.key,
                depth + 1,
                node.task.name,
                e.value,
              );
            }).toList(),
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
