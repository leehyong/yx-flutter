import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class WorkHeaderTree {
  var task = WorkHeader.create().obs;
  RxList<WorkHeaderTree> children;
  WorkHeaderTree(this.task, this.children);
}