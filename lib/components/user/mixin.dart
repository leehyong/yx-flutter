
import 'package:flutter/material.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

mixin CommonUserCenterView {
  UserCenterPageParams get pageParams;
  var confirming = false;
  Widget buildBody(BuildContext context);

  Widget buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageParams.action.i18name, style: defaultTitleStyle),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child:
        isBigScreen(context)
            ? ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: buildBody(context),
        )
            : buildBody(context),
      ),
    );
  }
}