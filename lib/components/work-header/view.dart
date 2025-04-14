import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/utils/common_widget.dart';

import 'controller.dart';
import 'header_tree.dart';

class OneWorkHeaderTreeView extends GetView<WorkHeaderController> {
  OneWorkHeaderTreeView(WorkHeaderTree headerTree, {super.key}) {
    rootHeaderTreeId = headerTree.task.value.id.toString();
    Get.put(WorkHeaderController(headerTree), tag: rootHeaderTreeId);
  }

  late final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  @override
  Widget build(BuildContext context) {
    return commonCard(
      Obx(() => _buildHeaderTreeByDfs(context, controller.headerTree)),
      borderRadius: 0.0,
    );
  }

  Widget _buildItemBox(Widget child) {
    return Container(
      decoration: BoxDecoration(color: Colors.greenAccent.shade100),
      child: child,
    );
  }

  Widget _buildOneHeaderItem(WorkHeaderTree node) {
    return IconButton(
      onPressed: () {
        debugPrint("add");
      },
      icon: Row(
        children: [Text(node.task.value.name), Icon(Icons.add, size: 12)],
      ),
    );
  }

  Widget _buildHeaderTreeByDfs(BuildContext context, WorkHeaderTree node) {
    if (node.children.isEmpty) {
      return _buildOneHeaderItem(node);
    }
    // todo 每项的背景色该怎么设置？
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        _buildOneHeaderItem(node),
        Expanded(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                node.children.map((e) {
                  return _buildHeaderTreeByDfs(context, e);
                }).toList(),
          ),
        ),
      ],
    );
  }
}
