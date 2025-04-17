import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

import 'header_tree.dart';

class WorkHeaderController extends GetxController {
  final RxList<WorkHeaderTree> children;
  final opsCount = 0.obs;

  WorkHeaderController(this.children);

  int get maxColumns {
    // dfs 求最大列数
    int calculateMaxDepth(List<WorkHeaderTree> children) {
      return 1 +
          children
              .map(
                (c) => c.children.isEmpty ? 1 : calculateMaxDepth(c.children),
              )
              .reduce((a, b) => a > b ? a : b);
    }

    return calculateMaxDepth(children) - 1;
  }

  int get maxRows {
    // dfs 求最大行数
    int calculateMaxRows(List<WorkHeaderTree> children) {
      return children.fold(
        0,
        (acc, cur) =>
            acc + (cur.children.isEmpty ? 1 : calculateMaxRows(cur.children)),
      );
    }

    return calculateMaxRows(children);
  }
}

class OneWorkHeaderItemController extends GetxController {
  final globalKey =GlobalKey();
  final RxList<WorkHeaderTree> children;
  final Rx<WorkHeader> task;
  final opsCount = 0.obs;

  OneWorkHeaderItemController(this.task, this.children);

  @override
  void onInit() {
    super.onInit();
    ever(children, (v){
      debugPrint("OneWorkHeaderItemController ss $v");
    });
  }
}
