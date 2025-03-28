import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/user_provider.dart';


class ChangePwdController extends GetxController {

  final GlobalKey formKey = GlobalKey<FormState>();
  var oldPwd = ''.obs;
  var newPwd = ''.obs;
  var checkPwd = ''.obs;
  var showOldPwd = false.obs;
  var showNewPwd = false.obs;
  var showCheckPwd = false.obs;
  var hasOldPwdError = false.obs;
  var hasNewPwdError = false.obs;
  var hasCheckPwdError = false.obs;

  final UserProvider _provider = Get.find();

  static RegExp pwdReg = RegExp(
    r'^(?:(?=.*[a-z])(?=.*[A-Z])|(?=.*[a-zA-Z])(?=.*\d)|(?=.*[a-zA-Z])(?=.*[\W_])|(?=.*\d)(?=.*[\W_])).{6,}$',
    caseSensitive: true,
  );

  static String pwdRegErrorTxt = "请输入至少6位字符密码";
  static String pwdNotMatchErrorTxt = "两次密码不匹配";

  // static String pwdRegErrorTxt = "请输入至少6个字符的密码";
  static String phoneRegErrorTxt = "手机号格式不对";


  // Future<void> sendCaptchaAction() async {
  //   sentCaptcha.value = await _provider.getPhoneCode(phone.value, pwd.value);
  //   sendingCaptcha.value = false;
  // }
  //
  Future<String> changePwd() async =>
      _provider.changePwd(oldPwd.value, newPwd.value);

}
