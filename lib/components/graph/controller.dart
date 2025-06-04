import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:group_button/group_button.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import '../../vo/room_vo.dart';

class GraphTaskController extends GetxController {

  final selectedTasks = <String>{}.obs;
  final graphViewType = GraphViewType.task.obs;
  final roomVoController = GroupButtonController();
  final selectedRoomOneValue = ''.obs;
  final selectedTaskOneValue = ''.obs;
  static const maxSelectedCharCnt = 4;
  final maxTaskDepth = 1.obs;
  final curTask = (null as WorkTask?).obs;
  GraphViewType get nextViewType => graphViewType.value.nextViewType;

  final allRooms =
      <RoomVo>[
        RoomVo(departmentId: "1", dutyDepartmentName: "xxdddd"),
        RoomVo(departmentId: "2", dutyDepartmentName: "vvddd"),
        RoomVo(departmentId: "3", dutyDepartmentName: "ggadas"),
      ].obs;

  final selectRoomIds = <String>[].obs;

  bool get selectedObjIsNotEmpty =>
      selectedTasks.isNotEmpty || selectRoomIds.isNotEmpty;

  Color? get selectedObjColor => selectedObjIsNotEmpty ? Colors.blue : null;

  void setSelectedRoomsData() {
    if (roomVoController.selectedIndexes.isEmpty) {
      selectedRoomOneValue.value = '';
      return;
    }
    selectRoomIds.value =
        allRooms.value.indexed
            .where((e) => roomVoController.selectedIndexes.contains(e.$1))
            .map((e) => e.$2.departmentId!)
            .toList();
    var moreThanOne = roomVoController.selectedIndexes.length > 1;
    var v = allRooms.value.indexed.firstWhere(
      (roomVo) => roomVoController.selectedIndexes.contains(roomVo.$1),
    );
    var rv = v.$2.dutyDepartmentName ?? '';
    if (rv.length > maxSelectedCharCnt) {
      rv = rv.substring(0, maxSelectedCharCnt);
    }
    selectedRoomOneValue.value = moreThanOne ? '$rv...' : rv;
  }
}
