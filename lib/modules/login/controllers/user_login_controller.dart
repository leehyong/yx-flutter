import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/api/user_provider.dart';
import 'package:yx/types.dart';

class UserLoginController extends GetxController {
  var  user = ''.obs;
  var pwd = ''.obs;
  var showPwd = false.obs;
  var captcha = ''.obs;
  var sentCaptcha = false.obs;

  static RegExp pwdReg = RegExp(
    // r'^(?![0-9]+$)(?!a-zA-Z]+$)[A-Za-z\\W]{"+2+","+10+"}$'
      r'\d{6,}'
    // r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[~@#$%\*-\+=:,\\?\[\]\{}]).{6,16}$'
  );
  final GlobalKey formKey = GlobalKey<FormState>();
  static RegExp userReg = RegExp(
      r"^[a-zA-Z][a-zA-Z0-9_\-@#]{4,}"
  );
  final UserProvider _provider = Get.find();

  static String userRegErrorTxt = "请输入不包括中文的至少5个字符的用户名：首字只能为大小写字母、其它字符包括特殊字符（-、_、@、#）";
  // static String pwdRegErrorTxt = "请输入至少6个字符的密码";
  static String pwdRegErrorTxt = "请输入至少6为字符的密码";
  static UserLoginController get to => Get.find();

  Future<String> sendCaptchaAction() async {
    var res =  await _provider.getCaptchaCode(user.value, userCaptchaCode);
    sentCaptcha.value = res.isEmpty;
    // sendingCaptcha.value = false;
    return res;
  }

  Future<String> login() async =>
      _provider.login('', pwd.value, captcha.value);

  get canSendCaptcha => false;
}