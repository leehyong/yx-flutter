import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class WorkHeaderTree {
  var task = WorkHeader.create();
  List<WorkHeaderTree> children = <WorkHeaderTree>[];
  WorkHeaderTree(this.task, this.children);
}