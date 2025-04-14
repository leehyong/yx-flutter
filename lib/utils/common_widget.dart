import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

Widget emptyWidget(
  BuildContext context, {
  double width = 200,
  double height = 200,
}) => TDEmpty(
  type: TDEmptyType.plain,
  // emptyText: '暂无数据',
  image: Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
      image: const DecorationImage(
        image: AssetImage('assets/images/empty.jpeg'),
      ),
    ),
  ),
);

Widget maybeOneThirdCenterHorizontal(Widget w) =>
    GetPlatform.isMobile ? w : Row(children: [Spacer(), w, Spacer()]);

Widget maybeOneThirdCenterVertical(Widget w) =>
    GetPlatform.isMobile ? w : Column(children: [Spacer(), w, Spacer()]);
