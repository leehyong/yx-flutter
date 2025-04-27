import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';

import '../../../work-header/controller.dart';
import '../../../work-header/data.dart';
import '../controller.dart';
import '../data.dart';

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
              oneItem.add(
                SubmitWorkHeaderItemView(
                  headerTree.task.id.toString(),
                  headerTree.children,
                ),
              );
              // return Column(children: oneItem);
              return commonCard(Column(children: oneItem), borderRadius: 0);
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
          controller.children.values
              .map((e) => _buildSubmitHeader(context, e))
              .toList(),
    );
  }

  Widget _buildSubmitHeaderItems(
    BuildContext context,
    SubmitOneWorkTaskHeader node,
  ) {
    if (node.head == null) {
      return SizedBox.shrink();
    }
    final wrapChildren = <Widget>[];
    for (var ph in node.parentHeads) {
      wrapChildren.add(Text(ph.name, style: TextStyle(fontSize: 10)));
      wrapChildren.add(const Text("/", style: TextStyle(fontSize: 10)));
    }
    wrapChildren.add(
      Text(
        node.head!.name,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
    if (node.head!.required) {
      wrapChildren.add(
        const Text(
          "*",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    return Wrap(runAlignment: WrapAlignment.end, children: wrapChildren);
  }

  Widget _buildSubmitHeader(
    BuildContext context,
    SubmitOneWorkTaskHeader node,
  ) {
    final w = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSubmitHeaderItems(context, node),
        TextField(
          controller: node.textEditingController,
          textInputAction: TextInputAction.send,
          autofocus: true,
          maxLines: 4,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
        ),
      ],
    );

    final colorIdx =
        (node.head?.id.toInt() ?? Random().nextInt(1000)) %
        loadingColors.length;
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
