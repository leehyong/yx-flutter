import 'package:get/get.dart';

import 'header_tree.dart';

class WorkHeaderController extends GetxController {
  final RxList<WorkHeaderTree> children;

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
