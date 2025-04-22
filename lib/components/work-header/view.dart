import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/utils/common_widget.dart';

import 'controller.dart';
import 'header_data.dart';

const columnWidths = {
  0: FixedColumnWidth(120), // 父表格第一列宽100
  1: FlexColumnWidth(), // 第二列自适应
};

class OneWorkHeaderTreeView extends GetView<WorkHeaderController> {
  OneWorkHeaderTreeView(
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
    return Obx(() => _buildTheHeaderTreeTable(context));
  }

  Widget _buildTheHeaderTreeTable(BuildContext context) {
    final oneTr = [];
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(),
      columnWidths: columnWidths,
      children: [
        ...controller.children.map((parent) => _buildOneRow(context, parent)),
      ],
    );
  }

  TableRow _buildOneRow(BuildContext context, WorkHeaderTree parent) {
    final tr = <Widget>[
      Center(child: IconButton(
        onPressed: () {
          debugPrint("add");
        },
        highlightColor: Colors.green.withValues(alpha: 0.5),
        icon: Tooltip(
          message: parent.task.name,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(parent.task.name, overflow: TextOverflow.ellipsis),
              Icon(Icons.add, size: 12, color: Colors.black),
              SizedBox(width: 4),
              buildTaskOpenRangeAndContentType(parent.task),
            ],
          ),
        ),
      )),
    ];
    tr.add(_buildChild(context, parent));
    return TableRow(children: tr);
  }

  Widget _buildChild(BuildContext context, WorkHeaderTree parent) {
    return OneWorkHeaderTreeView(
      parent.task.id.toString(),
      parent.children,
    );
  }
}
