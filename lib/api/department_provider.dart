import 'package:yx/api/provider.dart';
import 'package:get/get.dart';

import '../vo/common_vo.dart';
import '../vo/room_vo.dart';

class DepartmentProvider extends GlobalProvider {
  static DepartmentProvider get instance => Get.find();

  // 查询云网部科室列表
  Future<List<RoomVo>> getYunWangDepartmentRoomsList() async {
    try {
      var res = await post<CommonRoomVo>(
        "/flyBook/performance/duty/query-yunWang-list",
        null,
        decoder:
            (data) => CommonRoomVo.fromJson(
              data as Map<String, dynamic>,
              // fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
              fromJsonT:
                  deserializeRoomVoFromList
                      as FromJsonFn<List<RoomVo>?, List<dynamic>?>,
            ),
      );
      handleCommonToastResponse(res, 'dutyOrganGraphViewData错误');
      return res.body?.data ?? [];
    } catch (e) {
      e.printError(info: e.toString());
      return [];
    }
  }
}
