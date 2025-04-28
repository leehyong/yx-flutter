import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

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

Widget commonCard(
  Widget w, {
  double? elevation,
  Color? color,
  double? borderRadius,
  double? sideWidth,
  EdgeInsetsGeometry? margin,
}) => Card(
  margin: margin,
  color: color ?? Colors.blueGrey.shade50,
  // 设置卡片的阴影高度
  elevation: elevation ?? 12.0,
  // 设置卡片的形状
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
    side: BorderSide(color: Colors.blue.shade300, width: sideWidth ?? 1.0),
  ),
  child: w,
);

Widget buildTaskOpenRangeAndContentType(
  WorkHeader header, {
  bool isRow = false,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  double spacing = 2,
}) {
  final children = [
    TDBadge(
      TDBadgeType.message,
      color: Colors.yellowAccent,
      textColor: Colors.black,
      message: header.required ? "必填" : "可选",
    ),
    TDBadge(
      TDBadgeType.message,
      color: Colors.purpleAccent.shade100,
      textColor: Colors.black,
      message:
          header.contentType == unknownValue
              ? "未知"
              : TaskTextTypeExtension.fromInt(header.contentType).i18name,
    ),
    TDBadge(
      TDBadgeType.message,
      color: Colors.greenAccent,
      textColor: Colors.black,
      message:
          header.open == unknownValue
              ? "未知"
              : TaskOpenRangeExtension.fromInt(header.open).i18name,
    ),
  ];

  return isRow
      ? Row(
        spacing: spacing,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      )
      : Column(
        spacing: spacing,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
}
