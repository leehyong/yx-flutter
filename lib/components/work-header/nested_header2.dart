import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

import '../../utils/common_widget.dart';
import 'controller.dart';
import 'header_tree.dart';

class NestedDfsWorkHeaderTreeView extends GetView<WorkHeaderController> {
  NestedDfsWorkHeaderTreeView(
    this.rootHeaderTreeId,
    RxList<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(WorkHeaderController(children), tag: rootHeaderTreeId);
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  Widget _buildOneHeaderItem(int idx, WorkHeader task) {
    return Center(
      child: IconButton(
        onPressed: () {
          debugPrint("add");
        },
        highlightColor: Colors.green.withValues(alpha: 0.5),
        icon: Tooltip(
          message: task.name,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(task.name, overflow: TextOverflow.ellipsis),
              Icon(Icons.add, size: 12, color: Colors.black),
              SizedBox(width: 4),
              buildTaskOpenRangeAndContentType(task),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return LayoutBuilder(
  //     builder: (ctx, constraints) {
  //       return Container(
  //         constraints: BoxConstraints(
  //           minHeight: constraints.maxHeight,
  //           minWidth: constraints.maxWidth,
  //           maxWidth: double.infinity,
  //           maxHeight: double.infinity,
  //         ),
  //         child: SingleChildScrollView(
  //           scrollDirection: Axis.vertical,
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: CustomMultiChildLayout(
  //               delegate: NestedWorkHeaderTreeLayoutDelegate(
  //                 rootHeaderTreeId,
  //                 count: allHeaderItems.length,
  //                 rows: controller.maxRows,
  //                 columns: controller.maxColumns,
  //               ),
  //               children: allHeaderItems,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          controller.children
              .asMap()
              .entries
              .map((e) => _buildHeaderTreeByDfs(context, e.key, e.value))
              .toList(),
    );
  }

  Widget _buildHeaderTreeByDfs(
    BuildContext context,
    int idx,
    WorkHeaderTree node,
  ) {
    final w;
    if (node.children.isEmpty) {
      // 没有子节点时，独占一行
      w = Row(
        children: [Expanded(child: _buildOneHeaderItem(idx, node.task.value))],
      );
    } else {
      // 否则跟所有子节点一起放在同一行
      // todo 每项的背景色该怎么设置？
      w = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 4,
        children: [
          _buildOneHeaderItem(idx, node.task.value),
          Expanded(
            child: Column(
              // spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  node.children.asMap().entries.map((e) {
                    return _buildHeaderTreeByDfs(context, e.key, e.value);
                  }).toList(),
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(width: 1.0, color: Colors.black)),
        color:
            idx % 2 == 0 ? Colors.pink.shade200 : Colors.greenAccent.shade200,
      ),
      child: w,
    );
  }
}
