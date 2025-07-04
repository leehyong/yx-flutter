import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

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

// Widget maybeOneThirdCenterHorizontal(Widget w) =>
//     GetPlatform.isMobile ? w : Row(children: [Spacer(), Expanded(child: w), Spacer()]);
//
// Widget maybeOneThirdCenterVertical(Widget w) =>
//     GetPlatform.isMobile ? w : Column(children: [Spacer(), Expanded(child: w), Spacer()]);

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

Future<void> centerLoadingModal(
  BuildContext context,
  VoidFutureCallBack cb, {
  Indicator indicator = Indicator.ballClipRotatePulse,
  int waitingMilliSeconds = 200,
  double s = 200,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(125),
    barrierDismissible: false, // 用户不能点击背景关闭对话框
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent, // 对话框背景透明
        content: FutureBuilder(
          future: () async {
            cb().then((v) async {
              await Future.delayed(Duration(milliseconds: waitingMilliSeconds));
              if (context.mounted) {
                Navigator.of(context).maybePop();
              }
            });
          }(),
          builder: (context, snapshot) {
            return SizedBox(
              width: s,
              height: s,
              child: LoadingIndicator(
                indicatorType: indicator,
                colors: loadingColors,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    },
  );
}

Widget maskingOperation(
  BuildContext context,
  Widget target, {
  Indicator indicatorType = Indicator.lineScaleParty,
  Color? backgroundColor,
  double strokeWidth = 1.0,
  double size = 0.3,
  double? left,
  double? right,
  double? top,
  double? bottom,
  BorderRadiusGeometry? borderRadius,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          RepaintBoundary(child: target),
          Positioned(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.red.withAlpha(140),
                borderRadius: borderRadius ?? BorderRadius.circular(16.0),
              ),
              child: Center(
                child: SizedBox(
                  height: constraints.maxHeight * size,
                  width: constraints.maxWidth * size,
                  child: LoadingIndicator(
                    indicatorType: indicatorType,
                    colors: loadingColors,
                    strokeWidth: strokeWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget buildLoading(
  BuildContext context, {
  Indicator indicatorType = Indicator.lineSpinFadeLoader,
  double? strokeWidth,
}) {
  final s = isBigScreen(context) ? 100.0 : 80.0;
  return Center(
    child: SizedBox(
      height: s,
      width: s,
      child: LoadingIndicator(
        indicatorType: indicatorType,
        colors: loadingColors,
        strokeWidth: strokeWidth ?? 2.0,
      ),
    ),
  );
}

Widget buildLoadMoreTipAction(
  BuildContext context,
  bool hasMore,
  VoidCallback cb,
) =>
    hasMore
        ? TextButton(
          onPressed: cb,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Text('加载更多', style: TextStyle(color: Colors.blue)),
              Icon(Icons.more_horiz, color: Colors.blue),
            ],
          ),
        )
        : const Center(
          child: Text("没有更多数据了", style: TextStyle(color: Colors.grey)),
        );

Widget buildRandomColorfulBox(
  Widget target,
  int seed, {
  EdgeInsets? margin,
  EdgeInsets? padding,
  BorderRadiusGeometry? borderRadius,
}) {
  // 把颜色做成随机透明的
  final rand = Random(seed);
  final colorIdx = rand.nextInt(1000000) % loadingColors.length;
  final alpha = rand.nextInt(70) + 30;
  return RepaintBoundary(
    child: Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 2),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: loadingColors[colorIdx].withAlpha(alpha),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: target,
    ),
  );
}

Widget buildCreatorMyself({
  BorderRadiusGeometry? borderRadius,
  double? fontSize,
  EdgeInsets? padding,
}) => Container(
  padding: padding ?? EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: borderRadius ?? BorderRadius.circular(4),
  ),
  child: Text(
    '本人创建',
    style: TextStyle(color: Colors.white, fontSize: fontSize ?? 10.0),
  ),
);

Widget buildButton(
  BuildContext context, {
  required String name,
  required VoidCallback onPressed,
  VoidCallback? onLongPress,
  Color? bgColor,
  Color? fgColor,
  Color? color,
  EdgeInsetsGeometry? padding,
  TextStyle? nameStyle,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
    ),
    onPressed: onPressed,
    onLongPress: onLongPress,
    child: Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        name,
        style: nameStyle ?? TextStyle(fontSize: 24, color: color),
      ),
    ),
  );
}

enum ConfirmCancelButtonDirection { row, column }

Widget buildConfirmCancelButtons(
  BuildContext context, {
  required VoidCallback confirmPressed,
  required VoidCallback cancelPressed,
  MainAxisAlignment mainAlignment = MainAxisAlignment.center,
  CrossAxisAlignment crossAlignment = CrossAxisAlignment.center,
  ConfirmCancelButtonDirection direction = ConfirmCancelButtonDirection.row,
  double spacing = 20,
}) {
  final children = [
    buildButton(
      context,
      name: '取消',
      bgColor: Colors.grey.shade200,
      color: Colors.blueAccent.shade100,
      onPressed: cancelPressed,
    ),
    buildButton(context, name: '确定', onPressed: confirmPressed),
  ];

  switch (direction) {
    case ConfirmCancelButtonDirection.row:
      return Row(
        spacing: spacing,
        mainAxisAlignment: mainAlignment,
        crossAxisAlignment: crossAlignment,
        children: children,
      );
    case ConfirmCancelButtonDirection.column:
      return Column(
        spacing: spacing,
        mainAxisAlignment: mainAlignment,
        crossAxisAlignment: crossAlignment,
        children: children,
      );
  }
}
