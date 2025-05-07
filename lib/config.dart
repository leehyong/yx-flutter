import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

const publicKey =
    '046fa99b946d5ae8559287057264385b957218ceb09bc3dbff89c0d8fa1c84a73748c9969f2626e8434772972e7188c1aea2db6ed545f3ad0361242e3805141622';
// const apiServer = "https://flybook.gzdx.com.cn:30666";
// 使用内网穿透工具 ngrok， 来代理本地服务，从而使手机端可以访问
final apiServer =
    // GetPlatform.isMobile ? "https://10.0.2.2:18012" : "https://www.yoo.com:18012";
    GetPlatform.isMobile ? "https://deeply-included-polecat.ngrok-free.app" : "https://www.yoo.com:18012";

const xxCusHeaderOfAccessToken = 'xx-cus-token';
const accessTokenStr = 'access-token';

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
