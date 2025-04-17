import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import '../../utils/common_widget.dart';
import 'controller.dart';
import 'header_tree.dart';

class NestedDfsWorkHeaderTreeView extends GetView<WorkHeaderController> {
  NestedDfsWorkHeaderTreeView(
    this.rootHeaderTreeId,
    List<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(WorkHeaderController(children.obs), tag: rootHeaderTreeId);
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  Widget _buildOneHeaderItem(WorkHeaderTree task) {
    return Center(
      child: IconButton(
        onPressed: () {
          task.children.value.add(
            WorkHeaderTree(
              WorkHeader(
                name: "请输入填报项",
                id: Int64(0),
                contentType: 0,
                open: 0,
              ).obs,
              <WorkHeaderTree>[].obs,
            ),
          );
          controller.opsCount.value += 1;
          debugPrint("add");
        },
        highlightColor: Colors.green.withValues(alpha: 0.5),
        icon: Tooltip(
          message: task.task.value.name,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(task.task.value.name, overflow: TextOverflow.ellipsis),
              Icon(Icons.add, size: 12, color: Colors.black),
              SizedBox(width: 4),
              buildTaskOpenRangeAndContentType(task.task.value),
            ],
          ),
        ),
      ),
    );
  }

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
      w = Row(children: [Expanded(child: _buildOneHeaderItem(node))]);
    } else {
      // 否则跟所有子节点一起放在同一行
      // todo 每项的背景色该怎么设置？
      w = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 4,
        children: [
          _buildOneHeaderItem(node),
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
