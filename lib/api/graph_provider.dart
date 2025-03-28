import 'package:yx/vo/common_vo.dart';
import 'package:yx/vo/graph_vo.dart';
import 'package:get/get.dart';

import 'provider.dart';

class GraphTaskProvider extends GlobalProvider {
  static GraphTaskProvider get instance => Get.find();

  Future<CommonGraphVo?> dutyOrganGraphViewData(List<String> roomIds) async {
    try {
      var res = await post<CommonGraphVo>(
        "/flyBook/performance/duty/get-duty-organ",
        roomIds,
        decoder:
            (data) => CommonGraphVo.fromJson(
              data as Map<String, dynamic>,
              fromJsonT:
                  GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
            ),
      );
      // 消息通知 toast
      final success = handleCommonToastResponse(
        res,
        'dutyOrganGraphViewData错误',
      );
      return success ? res.body : null;
    } catch (e) {
      e.printError(info: e.toString());
      return null;
    }
  }

  Future<CommonGraphVo> queryAllTasks() async {
    try {
      // todo
      var res = await post<CommonGraphVo>(
        "/flyBook/performance/duty/query-duty-by-list",
        null,
        decoder:
            (data) => CommonGraphVo.fromJson(
              data as Map<String, dynamic>,
              fromJsonT:
                  GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
            ),
      );
      // 消息通知 toast
      final success = handleCommonToastResponse(res, 'queryAllTasks错误');
      return success ? res.body : null;
    } catch (e) {
      e.printError(info: e.toString());
      return null;
    }
  }
}
