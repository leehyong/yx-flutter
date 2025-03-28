import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:yx/api/user_provider.dart';
import 'package:yx/errors.dart';
import 'package:yx/services/auth_service.dart';
import 'package:yx/types.dart';

void main() {
  // test("test get", () async {
  //   final DepartmentProvider provider = DepartmentProvider();
  //   provider.onInit();
  //   var s = await provider.getYunWangDepartmentRoomsList();
  //   print(s);
  // });
  Get.put(AuthService());
  final userProvider = UserProvider();
  userProvider.onInit();

  test("login", () async {
    // 假的验证码
    final res = await userProvider.loginApi('admin', '123456', '112234');
    assert(!res.isOk);
    assert(res.status.code == 401);
    // 证明已经正确获取到了提交的参数
    assert(res.body == captchaExpired);
  });

  test("user login with captcha", () async {
    // 发送验证码之后再进行登录
    final user = 'admin';
    final captch = await userProvider.captchaCodeApi(user, userCaptchaCode);
    assert(captch.$1);
    final captcha = captch.$2.split("::");
    assert(captcha.length == 2);
    final res = await userProvider.login(user, '123456', captcha[0]);
    assert(res.isEmpty);
    assert(AuthService.to.refreshToken.isNotEmpty);
    assert(AuthService.to.accessToken.isNotEmpty);
    assert(AuthService.to.user == user);
    // 证明已经正确获取到了提交的参数
  });

  // test("test get", () async {
  //   // final UserProvider provider = UserProvider();
  //   final UserProvider provider = UserProvider();
  //   provider.onInit();
  //   var s = await provider.getPhoneCode(
  //     "19385512026",
  //     "11223344",
  //     isLog: false,
  //   );
  //   expect(s, true);
  // });
  //
  // test('encrypt&decrypt', () {
  //   const v = 'lhy';
  //   print(encrypt(v));
  //   const privatekey =
  //       'a40aca246d4321aa2cffbb5a6dc1a8a30f630a8740f6375d5f3f7c43cb8eccb7';
  //   const pubk =
  //       '0409a4b3068307d72326561ba88d3762c04c212f5880d1080ac4ebee30bcb44d3eae25db87b35e5ab6f8cab4baa549d7c05bf3e3513936236ce5d6d21731c020ac';
  //   // const expectv = '0483f187900c727b7d532e719f74bca60b1e0eed6f802c59ae970884d4477167a78b6d7c7c3038aef5d48828d43e44ef0002dbf30493d3c583d4c701e88fb2a0c7720503d5edd0b158005ee2def09c9949ebfc5800284b317eeb9ec89683f64d698ac6a4fb' ;
  //   var v2 = encrypt(v, pubKey: pubk);
  //   print(v2);
  //   expect(base64Encode(v.codeUnits), 'bGh5');
  //   // expect(v2, expectv);
  //   var dv = SM2.decrypt(v2, privatekey);
  //   expect(String.fromCharCodes(base64Decode(dv)), v);
  // });
  // test("json deserilize", () {
  //   var v = CommonVo.fromJson({
  //     "code": 200,
  //     "message": "data:image/gif;",
  //     "date": "2025-02-21 14:28:27",
  //   });
  //   expect(v.code, 200);
  //
  //   v = CommonVo.fromJson(
  //     jsonDecode('{"code": 200, "message": "22", "date": "2233"}'),
  //   );
  //   expect(v.code, 200);
  // });
}
