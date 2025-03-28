import 'dart:convert';

import 'package:yx/vo/comment_vo.dart';
import 'package:yx/vo/common_vo.dart';
import 'package:yx/vo/graph_vo.dart';
import 'package:yx/vo/room_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test graph json", () async {
    var str =
        '{"nodes":{"1":{"label":"内部数字化","children":["2","3"]},"2":{"label":"宽带室","children":["4","5"]}},"edges":[{"from":"1","to":"2"},{"from":"2","to":"3"},{"from":"2","to":"4"},{"from":"2","to":"5"},{"from":"5","to":"6"},{"from":"5","to":"7"},{"from":"6","to":"8"}]}';
    var vo = GraphVo.fromJson(jsonDecode(str));
    // var prettyJsonString = JsonEncoder.withIndent('  ').convert(vo);
    // print(prettyJsonString);
    expect(vo?.edges?[0].from, "1");
    expect(vo?.edges?[1].from, "2");
    expect(vo?.nodes?["1"]?.label, "内部数字化");
    expect(vo?.nodes?["2"]?.label, "宽带室");
  });
  test("graph json data", (){

    var str = '{"code":200,"message":"OK","data":{"nodes":{"1":{"label":"云网部（大数据AI中心）","role":null,"responsibleId":null,"responsible":null,"children":["1498548268815089664","1498548398960148480"]},"2":{"label":"日常工作","role":null,"responsibleId":null,"responsible":null,"children":["123"]},"123":{"label":"设备维护作业计划","role":"负责","responsibleId":null,"responsible":null,"children":[]},"124":{"label":"大会","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["128","129"]},"125":{"label":"考查","role":"负责","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"128":{"label":"大会1","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["130","131"]},"129":{"label":"大会2","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":["132","133"]},"130":{"label":"小会1","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"131":{"label":"小会2","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"132":{"label":"小会3","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"133":{"label":"小会4","role":"协助","responsibleId":"1585104683704254472","responsible":"谢龑","children":[]},"1498548268815089664":{"label":"机动通信室","role":null,"responsibleId":null,"responsible":null,"children":["2"]},"1498548398960148480":{"label":"应用研发室","role":null,"responsibleId":null,"responsible":null,"children":["2","2"]}},"edges":[{"from":"1","to":"1498548268815089664"},{"from":"1498548268815089664","to":"2"},{"from":"124","to":"128"},{"from":"124","to":"129"},{"from":"128","to":"130"},{"from":"128","to":"131"},{"from":"129","to":"132"},{"from":"129","to":"133"},{"from":"2","to":"124"},{"from":"2","to":"125"},{"from":"1","to":"1498548398960148480"},{"from":"1498548398960148480","to":"2"},{"from":"124","to":"128"},{"from":"124","to":"129"},{"from":"128","to":"130"},{"from":"128","to":"131"},{"from":"129","to":"132"},{"from":"129","to":"133"},{"from":"2","to":"124"},{"from":"1498548398960148480","to":"2"},{"from":"2","to":"123"}]},"date":"2025-02-2715:53:37"}';
    var data = jsonDecode(str);
    var vo = CommonGraphVo.fromJson(
      data as Map<String, dynamic>,
      fromJsonT: GraphVo.fromJson as FromJsonFn<GraphVo, CommonMapVoData>,
    );
    expect(vo?.code, 200);
    expect(vo?.message, "OK");

    // expect(vo?.data!.nodes!.length > 1, true);
    // expect(vo?.data!.edges!.length > 1, true);
  });


  test('room vo', (){
    var str =  '[{"departmentId":"1498547677502111744","dutyDepartmentName":"基础设施维护中心","centerName":"测试中心6"},{"departmentId":"1498547677502111746","dutyDepartmentName":"基础设施维护中心3","centerName":"测试中心6"},{"departmentId":"1498547677502111745","dutyDepartmentName":"基础设施维护中心2","centerName":"测试中心6"}]';
    var vo = deserializeRoomVoFromList(jsonDecode(str));
    expect(vo?.length, 3);
    expect(vo?[0].departmentId, '1498547677502111744');
  });

  test('comment vo', (){
    var str = '{"code":200,"message":"OK","data":{"count":2,"data":[{"delete":1,"edit":1,"id":"15789","dutyId":"127","evaluationAuthor":"杨帆","createDate":[2025,3,7],"evaluationDes":"好","evaluationReply":{"count":1,"data":[{"delete":1,"edit":1,"id":"1897850265227231232","dutyId":"127","evaluationAuthor":"超级管理员","createDate":[2025,3,7],"evaluationDes":"东方闪电"}]}},{"delete":1,"edit":1,"id":"15788","dutyId":"127","evaluationAuthor":"杨帆","createDate":[2025,3,7],"evaluationDes":"好HAO","evaluationReply":null}]},"date":"2025-03-10 16:19:26"}';
    var vo = CommonCommentVo.fromJson(
        jsonDecode(str) as CommonMapVoData,
        fromJsonT:
        CommentVo.fromJson as FromJsonFn<CommentVo, CommonMapVoData>);
    expect(vo?.code, 200);
    expect(vo?.message, "OK");
    var data = vo?.data;
    expect(data?.count, 2);
  });
}
