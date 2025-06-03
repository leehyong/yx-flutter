import 'package:get/get.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

import 'data.dart';


class MobileSubmitOneTaskHeaderItemController extends GetxController {
  late final List<SubmitOneWorkTaskHeader> children;

  // late final LinkedHashMap<int, SubmitOneWorkTaskHeader> children;
  MobileSubmitOneTaskHeaderItemController(List<CusYooHeaderTree> children) {
    // this.children = LinkedHashMap<int, SubmitOneWorkTaskHeader>();
    if (children.isEmpty) {
      this.children = [SubmitOneWorkTaskHeader()];
    } else {
      this.children = <SubmitOneWorkTaskHeader>[];
      _buildSubmitWorkHeaders(children);
    }
  }

  void _buildSubmitWorkHeaders(
    List<CusYooHeaderTree> headers, {
    List<WorkHeader>? parents,
  }) {
    for (var entry in headers) {
      final tmpParents = parents ?? [];
      if (entry.children.isEmpty) {
        children.add(SubmitOneWorkTaskHeader(entry.node, tmpParents));
      } else {
        tmpParents.add(entry.node);
        _buildSubmitWorkHeaders(entry.children, parents: tmpParents);
      }
    }
  }
}

class WebSubmitOneTaskHeaderItemController extends GetxController {
  final List<CusYooHeaderTree> children;

  WebSubmitOneTaskHeaderItemController(this.children);
}
