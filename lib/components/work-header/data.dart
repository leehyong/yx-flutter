import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class WorkHeaderTree {
  var header = WorkHeader.create();
  List<WorkHeaderTree> children = <WorkHeaderTree>[];

  WorkHeaderTree(this.header, this.children);
}

class CheckableWorkHeader {
  final WorkHeader header;
  bool checked;

  CheckableWorkHeader(this.header, [this.checked = false]);
}
