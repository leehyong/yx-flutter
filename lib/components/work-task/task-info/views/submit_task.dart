import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/utils/common_widget.dart';

import '../../../work-header/controller.dart';
import '../../../work-header/data.dart';
import '../controller.dart';
import '../data.dart';

// 填报任务项的时候使用它
// todo： title 展示任务名， 并且可以查看任务的信息
class MobileSubmitTasksView extends GetView<SubmitTasksController> {
  MobileSubmitTasksView({super.key}) {
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
                    buildTaskOpenRangeAndContentType(root.task, isRow: true),
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
            cacheExtent: 100,
            controller: controller.scrollController,
            // addRepaintBoundaries:t,
            itemCount: controller.isLoadingSubmitItem.value ? cnt + 1 : cnt,
            itemBuilder: (ctx, idx) {
              final headerTree = submitItems[idx];
              final oneItem = [_buildRootHeaderNameTable(context, headerTree)];
              oneItem.add(
                SubmitWorkHeaderItemView(
                  headerTree.task.id.toString(),
                  headerTree.children,
                ),
              );
              return commonCard(
                Column(children: oneItem),
                borderRadius: 0,
                margin: EdgeInsets.only(bottom: 16),
              );
            },
          ),
        );
      },
    );
  }
}

class SubmitWorkHeaderItemView
    extends GetView<SubmitOneTaskHeaderItemController> {
  SubmitWorkHeaderItemView(
    this.rootHeaderTreeId,
    List<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(SubmitOneTaskHeaderItemController(children), tag: rootHeaderTreeId);
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          controller.children.map((e) => _buildSubmitItem(context, e)).toList(),
    );
  }

  Widget? _buildSubmitHeaders(
    BuildContext context,
    SubmitOneWorkTaskHeader node,
  ) {
    if (node.head == null) {
      return null;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(width: 1.0, color: Colors.white),
        ),
        color: Colors.yellow.withAlpha(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...node.parentHeads.map(
            (e) => Row(
              children: [
                Text(e.name, style: TextStyle(fontSize: 10, color: Colors.black)),
                const Text("/", style: TextStyle(fontSize: 10, color: Colors.black)),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                node.head!.name,
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                softWrap: true,
                // overflow: TextOverflow.ellipsis,
              ),
              if (node.head!.required)
                const Text(
                  "*",
                  style: TextStyle(
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitItem(BuildContext context, SubmitOneWorkTaskHeader node) {
    final h = _buildSubmitHeaders(context, node);
    final children = <Widget>[];
    if (h != null) {
      children.add(Expanded(flex: 1, child: h));
    }
    children.add(
      Expanded(
        flex: h != null ? 3 : 1,
        child: TextField(
          controller: node.textEditingController,
          textInputAction: TextInputAction.done,
          autofocus: true,
          maxLines: 4,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
    final w = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
    return w;
  }
}
