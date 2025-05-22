import 'package:yt_dart/generate_sea_orm_query.pb.dart';

class CheckableWorkHeader {
  final WorkHeader header;
  final bool db;
  bool checked;

  CheckableWorkHeader({
    required this.header,
    required this.db,
    this.checked = false,
  });
}
