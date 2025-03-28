import 'package:flutter/cupertino.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

Widget emptyWidget(BuildContext context,
    {
      double width=200,
      double height=200,
    }) => TDEmpty(
  type: TDEmptyType.plain,
  // emptyText: '暂无数据',
  image: Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
      image: const DecorationImage(
        image: AssetImage( 'assets/images/empty.jpeg'),
      ),
    ),
  ),
);
