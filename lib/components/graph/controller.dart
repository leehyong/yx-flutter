import 'dart:convert';

import 'package:yx/api/department_provider.dart';
import 'package:yx/api/user_provider.dart';
import 'package:yx/types.dart';
import 'package:yx/vo/graph_vo.dart' as graph_vo;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:graphview/GraphView.dart';
import 'package:group_button/group_button.dart';

import '../../api/graph_provider.dart';
import '../../vo/common_vo.dart';
import '../../vo/room_vo.dart';
import '../checkable-treeview/treeview.dart';

class GraphTaskController extends GetxController {
  static const initSource =
      '{"nodes":{"1":{"label":"内部数字化统筹室","children":["2","3"]},"2":{"label":"宽带室","children":["4","5"]}},"edges":[{"from":"1","to":"2"},{"from":"2","to":"3"},{"from":"2","to":"4"},{"from":"2","to":"5"},{"from":"5","to":"6"},{"from":"5","to":"7"},{"from":"6","to":"8"}]}';

  static GraphTaskController get instance => Get.find();
  final treeViewTaskKey = GlobalKey<TreeViewState<String>>();
  final selectedTasks = <String>{}.obs;
  final roomVoController = GroupButtonController();
  final graphVoData = (null as graph_vo.GraphVo?).obs;
  final graph = (null as Graph?).obs;
  final loadingData = DataLoadingStatus.none.obs;
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horintalScrollController = ScrollController();
  final selectedRoomOneValue = ''.obs;
  final selectedTaskOneValue = ''.obs;
  static const maxSelectedCharCnt = 4;
  final maxTaskDepth = 1.obs;
  final curTaskNode = (null as graph_vo.Node?).obs;
  final curTaskId = ''.obs;

  final BuchheimWalkerConfiguration graphBuilder =
      BuchheimWalkerConfiguration()
        ..siblingSeparation = (100)
        ..levelSeparation = (20)
        ..subtreeSeparation = (60)
        ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  final allRooms =
      <RoomVo>[
        RoomVo(departmentId: "1", dutyDepartmentName: "xxdddd"),
        RoomVo(departmentId: "2", dutyDepartmentName: "vvddd"),
        RoomVo(departmentId: "3", dutyDepartmentName: "ggadas"),
      ].obs;
  final allTasks =
      [
        // MultiSelectDataItem("1", "日常安全"),
        // MultiSelectDataItem("2", "科技创新"),
        // MultiSelectDataItem("3", "基础运营"),
        // MultiSelectDataItem("4", "双提升"),
      ].obs;

  final selectRoomIds = <String>[].obs;

  bool get selectedObjIsNotEmpty =>
      selectedTasks.isNotEmpty || selectRoomIds.isNotEmpty;

  Color? get selectedObjColor => selectedObjIsNotEmpty ? Colors.blue : null;

  @override
  void onInit() async {
    super.onInit();

    await Future.wait([
      UserProvider.instance.getUserByOrgId('1498548398960148480'),
      setRoomData(),

      setGraphViewData()]);
  }

  void setSelectedTaskOneValue() {
    var st = treeViewTaskKey.currentState?.getSelectedNodes();
    if (st == null || st.isEmpty) {
      selectedTaskOneValue.value = '';
    } else {
      var firstVal = st.first.value!;
      if (firstVal.length > maxSelectedCharCnt) {
        firstVal = firstVal.substring(0, maxSelectedCharCnt);
      }
      selectedTaskOneValue.value = st.length > 1 ? '$firstVal...' : firstVal;
    }
  }

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

  Future<void> setRoomData() async {
    var depsData =
        await DepartmentProvider.instance.getYunWangDepartmentRoomsList();
    if (depsData.isNotEmpty) {
      allRooms.value = depsData;
    }
  }

  Future<void> setGraphViewData() async {
    loadingData.value = DataLoadingStatus.loading;
    graphVoData.value = null;
    var data = await GraphTaskProvider.instance.dutyOrganGraphViewData(
      selectRoomIds.value,
    );
    if (data != null) {
      // 设置默认值
      graphVoData.value =
          data.data ?? graph_vo.GraphVo.fromJson(jsonDecode(initSource));
    } else {
      var str =
          '{"code":200,"message":"OK","data":{"nodes":{"1":{"label":"云网部（大数据AI中心）","role":null,"responsibleId":null,"responsible":null,"children":["1498548268815089664","1498548398960148480"]},"2":{"label":"日常工作","role":null,"responsibleId":null,"responsible":null,"children":["123"]},"123":{"label":"设备维护作业计划","role":"负责","responsibleId":null,"responsible":null,"children":[]},"124":{"label":"大会","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["128","129"]},"125":{"label":"考查","role":"负责","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"128":{"label":"大会1","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["130","131"]},"129":{"label":"大会2","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["132","133"]},"130":{"label":"小会1","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"131":{"label":"小会2","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"132":{"label":"小会3","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"133":{"label":"小会4","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"1498548268815089664":{"label":"机动通信室","role":null,"responsibleId":null,"responsible":null,"children":["2"]},"1498548398960148480":{"label":"应用研发室","role":null,"responsibleId":null,"responsible":null,"children":["2","2"]}},"edges":[{"from":"1","to":"1498548268815089664"},{"from":"1498548268815089664","to":"2"},{"from":"124","to":"128"},{"from":"124","to":"129"},{"from":"128","to":"130"},{"from":"128","to":"131"},{"from":"129","to":"132"},{"from":"129","to":"133"},{"from":"2","to":"124"},{"from":"2","to":"125"},{"from":"1","to":"1498548398960148480"},{"from":"124","to":"128"},{"from":"124","to":"129"},{"from":"128","to":"130"},{"from":"128","to":"131"},{"from":"129","to":"132"},{"from":"129","to":"133"},{"from":"2","to":"124"},{"from":"2","to":"123"}]},"date":"2025-02-2715:53:37"}';
      var data2 = jsonDecode(str);
      var vo = graph_vo.CommonGraphVo.fromJson(
        data2 as Map<String, dynamic>,
        fromJsonT:
            graph_vo.GraphVo.fromJson
                as FromJsonFn<graph_vo.GraphVo, CommonMapVoData>,
      );
      graphVoData.value = vo!.data!;
      // graphVoData.value =  GraphVo.fromJson(jsonDecode(initSource));
    }
    setGraphEdges();
    loadingData.value = DataLoadingStatus.loaded;
  }

  void setGraphEdges() {
    graph.value = Graph()..isTree = true;
    graphVoData.value?.edges?.forEach((element) {
      var fromNodeId = element.from;
      var toNodeId = element.to;
      graph.value!.addEdge(Node.Id(fromNodeId), Node.Id(toNodeId));
    });
  }
}
