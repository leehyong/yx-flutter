import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

class CheckableWorkTask {
  final WorkTask task;
  bool checked;
  bool hidden;

  CheckableWorkTask(this.task, {this.checked = false, this.hidden = false});
}

WorkTask newFakeEmptyWorkTask({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  final start = DateTime.now().add(
    Duration(days: max(Random().nextInt(180), 4)),
  );
  final startDt = (start.millisecondsSinceEpoch / 1000).toInt();
  final end = start.add(Duration(days: max(Random().nextInt(30), 1)));
  return WorkTask(
    name: "任务-${name ?? key}",
    id: id,
    content: "ccc${Random().nextDouble() * 100000}",
    contactor: "bb",
    contactPhone: "1553209${Random().nextInt(100).toString().padLeft(2)}",
    receiveStrategy: Random().nextInt(ReceiveTaskStrategy.values.length),
    creditsStrategy: Random().nextInt(TaskCreditStrategy.values.length),
    credits: Random().nextDouble() * max(Random().nextInt(1000), 10),
    planStartDt: Int64(startDt),
    planEndDt: Int64((end.millisecondsSinceEpoch / 1000).toInt()),
    receiveDeadline: Int64(
      (start
                  .subtract(Duration(days: max(1, Random().nextInt(3))))
                  .millisecondsSinceEpoch /
              1000)
          .toInt(),
    ),
  );
}

Organization newFakeEmptyOrg({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  final start = DateTime.now().add(
    Duration(days: max(Random().nextInt(180), 4)),
  );
  final startDt = (start.millisecondsSinceEpoch / 1000).toInt();
  final end = start.add(Duration(days: max(Random().nextInt(30), 1)));
  return Organization(
    name: "组织-${name ?? key}",
    id: id,
    address: "ccc${Random().nextDouble() * 100000}",
    remark: "bb",
  );
}

User newFakeEmptyUser({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  return User(
    name: "用户-${name ?? key}",
    id: id,
    email: "ccc@lee${Random().nextDouble() * 100000}.com",
    phone: "1553209${Random().nextInt(100).toString().padLeft(2)}",
  );
}

class CheckableOrganizationOrUser {
  final Object data;
  bool checked;
  bool hidden;

  String get name {
    if (data is User)
      return (data as User).name;
    else if (data is Organization)
      return (data as Organization).name;
    else {
      throw UnsupportedError("不支持的类型");
    }
  }

  Int64 get id {
    if (data is User)
      return (data as User).id;
    else if (data is Organization)
      return (data as Organization).id;
    else {
      throw UnsupportedError("不支持的类型");
    }
  }

  CheckableOrganizationOrUser(
    this.data, {
    this.checked = false,
    this.hidden = false,
  });
}
