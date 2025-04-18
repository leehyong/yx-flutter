import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class WorkHeaderTree {
  var task = WorkHeader.create().obs;
  RxList<Rx<WorkHeaderTree>> children = <Rx<WorkHeaderTree>>[].obs;
  WorkHeaderTree(this.task, this.children);
}