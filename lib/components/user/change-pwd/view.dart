import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/user/change-pwd/controller/change_pwd.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/types.dart';

import '../mixin.dart';
import 'views/change_pwd_comp.dart';

class ChangePwdVIew extends StatefulWidget {
  ChangePwdVIew({super.key, required this.params}) {
    assert(params.action == UserCenterAction.changePwd);
  }

  final UserCenterPageParams params;

  @override
  ChangePwdVIewState createState() => ChangePwdVIewState();
}

class ChangePwdVIewState extends State<ChangePwdVIew>
    with CommonUserCenterView {

  @override
  void initState() {
    super.initState();
    Get.put(ChangePwdController());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Get.delete<ChangePwdController>();
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);

  @override
  Widget buildBody(BuildContext context) => ChangePwdCompView(cancelRouteId: NestedNavigatorKeyId.userCenterId);

  @override
  UserCenterPageParams get pageParams => widget.params;
}
