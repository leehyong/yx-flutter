import 'package:flutter/material.dart';

export 'config/web.dart' if (dart.library.io) 'config/native.dart';

const publicKey =
    '046fa99b946d5ae8559287057264385b957218ceb09bc3dbff89c0d8fa1c84a73748c9969f2626e8434772972e7188c1aea2db6ed545f3ad0361242e3805141622';

const accessTokenStr = 'authorization';

List<BoxShadow> getNodeBgColor(String? typ) {
  switch (typ) {
    // 部门
    case 'department':
      return [BoxShadow(color: Colors.red[100]!, spreadRadius: 1)];
    // 科室
    case 'section':
      return [BoxShadow(color: Colors.orange[100]!, spreadRadius: 1)];
    // 任务类型
    case 'dutyType':
      return [BoxShadow(color: Colors.blueGrey[100]!, spreadRadius: 1)];
    default:
      return [BoxShadow(color: Colors.blue[100]!, spreadRadius: 1)];
  }
}
