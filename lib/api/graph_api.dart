import 'package:get/get.dart';
import 'package:yx/services/http_service.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/vo/graph_vo.dart';


  Future<CommonGraphVo?> dutyOrganGraphViewData(List<String> roomIds) async {
    try {
      var res = await HttpDioService.instance.dio.post<CommonGraphVo>(
        "/flyBook/performance/duty/get-duty-organ",
        data: roomIds,
        // decoder:
        //     (data) => CommonGraphVo.fromJson(
        //       data as Map<String, dynamic>,
        //       fromJsonT:
        //           GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
        //     ),
      );
      // 消息通知 toast
      final success = handleCommonToastResponse(
        res,
        'dutyOrganGraphViewData错误',
      );
      return success ? res.data : null;
    } catch (e) {
      e.printError(info: e.toString());
      return null;
    }
  }

  Future<CommonGraphVo> queryAllTasks() async {
    try {
      // todo
      var res = await HttpDioService.instance.dio.post<CommonGraphVo>(
        "/flyBook/performance/duty/query-duty-by-list",
        // null,
        // decoder:
        //     (data) => CommonGraphVo.fromJson(
        //       data as Map<String, dynamic>,
        //       fromJsonT:
        //           GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
        //     ),
      );
      // 消息通知 toast
      final success = handleCommonToastResponse(res, 'queryAllTasks错误');
      return success ? res.data : null;
    } catch (e) {
      e.printError(info: e.toString());
      return null;
    }
  }
