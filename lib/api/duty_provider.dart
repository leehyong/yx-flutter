import 'package:yx/api/provider.dart';
import 'package:yx/vo/duty_vo.dart';
import 'package:get/get.dart';

import '../vo/common_vo.dart';

class DutyProvider extends GlobalProvider {
  //创建任务
  void createDuty(DutyVo dutyVo) async {
    try {
      var res = await post<CommonVo>(
        "/flyBook/performance/duty/create-duty",
        dutyVo.toJson(),
        decoder: (data) {
          // print(data);
          return CommonVo.fromJson(data as Map<String, dynamic>);
        },
      );
      handleCommonToastResponse(res, '上传失败');
    } catch (e) {
      e.printError(info: e.toString());
    }
  }

  //根据用户id获取任务列表
  Future<List<DutyVo>> getDutyList() async {
    try {
      var res = await post<CommonDutyVo>(
        "/flyBook/performance/duty/query-duty-by-list",
        null,
        decoder:
            (data) => CommonDutyVo.fromJson(
              data as Map<String, dynamic>,
              // fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
              fromJsonT:
                  deserializeDutyFromList
                      as FromJsonFn<List<DutyVo>?, List<dynamic>?>,
            ),
      );
      // 消息通知 toast
      handleCommonToastResponse(res, 'UserData错误');
      return res.body?.data ?? [];
    } catch (e) {
      e.printError(info: e.toString());
      return [];
    }
  }
}
