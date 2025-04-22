import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

import '../../utils/common_widget.dart';
import 'controller.dart';
import 'header_data.dart';

class NestedWorkHeaderTreeView extends GetView<WorkHeaderController> {
  NestedWorkHeaderTreeView(
    this.rootHeaderTreeId,
    RxList<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(WorkHeaderController(children), tag: rootHeaderTreeId);
    allHeaderItems = children
        .asMap()
        .entries
        .map((c) => _buildAllHeaders(c.key, c.value))
        .fold([], (value, element) {
          value.addAll(element);
          return value;
        });
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  late final List<Widget> allHeaderItems;

  Widget _buildOneHeaderItem(int idx, WorkHeader task) {
    return LayoutId(
      id: task.id,
      child: Container(
        decoration: BoxDecoration(
          color:
              idx % 2 == 0 ? Colors.pink.shade200 : Colors.greenAccent.shade200,
        ),
        child: Center(
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
        ),
      ),
    );
  }

  List<Widget> _buildAllHeaders(int idx, WorkHeaderTree tree) {
    final items = <Widget>[_buildOneHeaderItem(idx, tree.task)];
    for (var header in tree.children.asMap().entries) {
      items.addAll(_buildAllHeaders(header.key, header.value));
    }
    return items;
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
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: min(constraints.maxHeight, 400),
          child: CustomMultiChildLayout(
            delegate: NestedWorkHeaderTreeLayoutDelegate(
              rootHeaderTreeId,
              count: allHeaderItems.length,
              rows: controller.maxRows,
              columns: controller.maxColumns,
            ),
            children: allHeaderItems,
          ),
        );
      },
    );
  }
}

class NestedWorkHeaderTreeLayoutDelegate extends MultiChildLayoutDelegate {
  NestedWorkHeaderTreeLayoutDelegate(
    this.rootHeaderTreeId, {
    required this.count,
    required this.columns,
    required this.rows,
    this.cellWidth = 100,
    this.cellHeight = 60,
  });

  final String rootHeaderTreeId;
  final int count;
  final int columns;
  final int rows;

  //  约束每个叶节点的大小为固定的宽高，父节点的高度是所有节点的累积
  final double cellWidth;
  final double cellHeight;

  WorkHeaderController get controller => Get.find(tag: rootHeaderTreeId);

  int _performOneHeaderLayout(WorkHeaderTree tree, int row, int column) {
    // 先布局子节点，
    var totalChildrenSize = Size.zero;
    var idx = 0;
    // 递归布局所有子节点
    for (var child in tree.children) {
      // 累加所有子节点的高度
      _performOneHeaderLayout(
        child,
        row + idx,
        column + 1,
      );
      idx += 1;
    }

    // 子节点布局完之后再布局 tree 节点
    //   叶节点的处理方法
    // 通过剩余多少列来计算还剩下多少宽度可布局
    final nthCol = columns - column;
    final width = nthCol * cellWidth;
    layoutChild(
      tree.task.id,
      BoxConstraints.tightFor(
        width: width,
        height: cellHeight,
      ),
    );
    positionChild(
      tree.task.id,
      Offset((nthCol - 1) * width, row * cellHeight),
    );

    // 下一个节点开始布局的行索引
    return row + idx + 1;
  }

  @override
  void performLayout(Size size) {
    int curRow = 0;
    for (var tree in controller.children) {
      if (hasChild(tree.task.id)) {
        curRow = _performOneHeaderLayout(tree, curRow, 0);
      }
    }
  }

  @override
  bool shouldRelayout(
    covariant NestedWorkHeaderTreeLayoutDelegate oldDelegate,
  ) {
    final old = oldDelegate;
    // 先简单比较，后续再看是否优化
    return oldDelegate != this ||
        old.rootHeaderTreeId != rootHeaderTreeId ||
        old.count != count;
  }
}
