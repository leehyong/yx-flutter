import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';


WorkHeader newEmptyWorkHeader({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  return WorkHeader(
    name: name == null ? '': "子项-$name",
    id: id,
    contentType: unknownValue,
    open: Random().nextInt(TaskOpenRange.values.length),
    required: Random().nextBool(),
  );
}

TreeNode<WorkHeader> newEmptyHeaderTree({WorkHeader? data}) {
  String key;
  if (data == null) {
    final id = Int64(DateTime.now().microsecondsSinceEpoch);
    key = "$id$innerNodeKey";
    data = newEmptyWorkHeader();
  } else {
    key = "${data.id}$innerNodeKey";
  }
  return TreeNode(key: key, data: data);
}
