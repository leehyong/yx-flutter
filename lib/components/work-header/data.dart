import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class CheckableWorkHeader {
  final WorkHeader header;
  bool checked;

  CheckableWorkHeader(this.header, [this.checked = false]);
}
