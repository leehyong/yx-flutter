import 'dart:async';

import 'package:color_palette_plus/color_palette_plus.dart';
import 'package:dio/dio.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yx/utils/proto.dart';
import 'package:yx/utils/toast.dart';
import 'package:yx/vo/common_vo.dart';

import '../types.dart' show innerNodeKey;

final defaultDtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final defaultDtFormat1 = DateFormat('yyyy-MM-dd HH:mm');

final defaultDateFormat = DateFormat('yyyy-MM-dd');
final defaultDateFormat1 = DateFormat('yyyy/MM/dd');
final twoValidNumber = NumberFormat('0.##');

DateTime dtLocalFromMilliSecondsTimestamp(int milliSeconds) =>
    DateTime.fromMillisecondsSinceEpoch(milliSeconds * 1000, isUtc: false);

String localFromSeconds(int seconds) =>
    defaultDtFormat.format(dtLocalFromMilliSecondsTimestamp(seconds));

String localDateFromSeconds(int seconds) =>
    defaultDateFormat.format(dtLocalFromMilliSecondsTimestamp(seconds));

Int64 parseDateFromSecond(String dt) {
  final d = parseDateFromStr(dt);
  return d == null ? Int64.ZERO : Int64(d!.millisecondsSinceEpoch ~/ 1000);
}

Int64 parseDateTimeFromSecond(String dt) {
  final d = parseDatetimeFromStr(dt);
  return d == null ? Int64.ZERO : Int64(d!.millisecondsSinceEpoch ~/ 1000);
}

String inputTxtFromDtSecond(Int64? seconds) =>
    seconds == null || seconds == Int64.ZERO
        ? ''
        : localFromSeconds(seconds.toInt());

Future<DateTime> showCusDateTimePicker(BuildContext context, {
  DateTime? dt,
}) async {
  var fullDateTime = DateTime.now();
  DateTime date = await showCusDatePicker(context, dt: dt);
  if (context.mounted) {
    TimeOfDay td;
    if (dt != null) {
      td = TimeOfDay(hour: dt.hour, minute: dt.minute);
    } else {
      td = TimeOfDay.now();
    }
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: td,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time == null) return date;

    fullDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
  return fullDateTime;
}

Future<DateTime> showCusDatePicker(BuildContext context, {DateTime? dt}) async {
  final now = dt ?? DateTime.now();
  return await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now.subtract(Duration(days: 15)),
    lastDate: now.add(Duration(days: 365 * 5)),
  ) ??
      now;
}

DateTime? parseDateFromStr(String dtStr) {
  for (var e in [defaultDateFormat, defaultDateFormat1]) {
    try {
      return e.parseStrict(dtStr);
    } on FormatException {
      continue;
    }
  }
  return null;
}

DateTime? parseDatetimeFromStr(String dtStr) {
  for (var e in [defaultDtFormat, defaultDtFormat1]) {
    try {
      return e.parseStrict(dtStr);
    } on FormatException {
      continue;
    }
  }
  return null;
}

Color getHighContrastColor(Color baseColor) {
  final complementaryColors = ColorPalettes.complementary(
    baseColor,
  ); // 生成互补色（高对比度）
  return complementaryColors.last;
  // final theme = ThemeGenerator.generateTheme(baseColor, config: ThemeConfig(
  //   colorSchemeConfig:  ColorSchemeConfig(harmonyType: HarmonyType.complementary,)
  //    // 使用互补色方案
  // ));
  final hsl = HSLColor.fromColor(baseColor);
  // 提高亮度或降低亮度以增强对比度
  return hsl.withLightness(hsl.lightness > 0.5 ? 0.1 : 0.9).toColor();
}

WoltModalType woltModalType(BuildContext context) {
  final width = MediaQuery
      .sizeOf(context)
      .width;
  if (width < 600) {
    return const WoltBottomSheetType(showDragHandle: false);
  } else if (width < 1000) {
    return WoltModalType.dialog();
  } else {
    return WoltModalType.sideSheet();
  }
}

bool isBigScreen(BuildContext context) =>
    MediaQuery
        .of(context)
        .size
        .width > 720;

bool isOkResponse(Response<dynamic> resp) =>
    resp.statusCode != null && resp.statusCode! ~/ 100 == 2;

bool handleCommonToastResponse(Response<CommonVo<dynamic, dynamic>?> res,
    String defaultMsg,) {
  return handleCommonToastResponseErr(res, defaultMsg).isEmpty;
}

String handleCommonToastResponseErr(Response<CommonVo<dynamic, dynamic>?> res,
    String defaultMsg,) {
  final err = isOkResponse(res);
  var errMsg = '';
  if (!err) {
    errMsg = res.data?.message ?? res.statusMessage ?? defaultMsg;
    errToast(errMsg);
  }
  return errMsg;
}

typedef ProtoBufferParser<T extends $pb.GeneratedMessage> =
T Function(List<int>);

(String?, T?) handleProtoInstanceVo<T extends $pb.GeneratedMessage>(
    Response<String> res,
    ProtoBufferParser<T> parser,) {
  final ret = decodeCommonVoDataFromResponse(res);
  var err = ret.$1;
  if (err == null) {
    final data = ret.$2!;
    return (null, parser(data.data.value));
  } else {
    errToast(err);
    return (err, null);
  }
}

class ProtoPageVo<T extends $pb.GeneratedMessage> {
  final String? error;
  final int page;
  final int totalPages;
  final int limit;
  final List<T>? data;

  ProtoPageVo._({
    this.data,
    this.error,
    this.page = 0,
    this.totalPages = 0,
    this.limit = 0,
  });

  factory ProtoPageVo.success(List<T> data,
      int page,
      int totalPages,
      int limit,) =>
      ProtoPageVo._(
        data: data,
        page: page,
        totalPages: totalPages,
        limit: limit,
      );

  factory ProtoPageVo.fail(String error) => ProtoPageVo._(error: error);
}

ProtoPageVo<T> handleProtoPageInstanceVo<T extends $pb.GeneratedMessage>(
    Response<String> res,
    ProtoBufferParser<T> parser,) {
  final ret = decodeCommonPageVoDataFromResponse(res);
  var err = ret.$1;
  if (err == null) {
    final data = ret.$2!;
    return ProtoPageVo<T>.success(
      data.data.map((item) => parser(item.value)).toList(),
      data.page,
      data.total,
      data.limit,
    );
  } else {
    errToast(err);
    return ProtoPageVo<T>.fail(err);
  }
}

String? handleProtoCommonInstanceVo(Response<String> response, {
  bool toastSuccess = false,
}) {
  final res = decodeCommonVoDataFromResponse(response);
  final err = res.$1;
  if (err == null) {
    if (toastSuccess) {
      okToast(res.$2!.msg);
    }
    return null;
  } else {
    debugPrint(err);
    errToast(err);
    return err;
  }
}

Int64? handleProtoCommonInstanceVoForMsgIncludeInt64(Response<String> response,
    {
      bool toastSuccess = false,
    }) {
  // 处理 msg的位置放置的是 id 的情况
  final res = decodeCommonVoDataFromResponse(response);
  final err = res.$1;
  if (err == null) {
    // 格式 id:::文本消息
    final successMsg = res.$2!.msg.split(":::");
    assert(successMsg.length == 2);
    if (toastSuccess) {
      okToast(successMsg[1]);
    }
    // fixme: 是否要用 dart ffi里的Int64来解析
    return Int64(int.parse(successMsg[0]));
  } else {
    errToast(err);
    debugPrint(err);
    return null;
  }
}

bool isValidPwd(String pwd) {
  // 至少6个字符，最多20个字符，且不包含空白字符
  // \S 匹配任意非空白字符
  if (!RegExp(r'^\S{6,20}$').hasMatch(pwd)) return false;

  final specialChars = r'''[\^~`!@#$%&*()\-_+={\[\]}}\\、:;'",<>./?]''';
  // 仅允许字母、数字、特殊字符
  // if (!RegExp(r'^[A-Za-z\d~`!@#$%^&*()-_=+{[}]\、;\:"<,>./?]+$').hasMatch(pwd)) return false;
  if (!RegExp('^(\\w|$specialChars)+\$').hasMatch(pwd)) return false;
  // 统计包含的字符类别数（至少3类）
  int categories = 0;
  if (RegExp(r'[A-Z]').hasMatch(pwd)) categories++; // 大写字母
  if (RegExp(r'[a-z]').hasMatch(pwd)) categories++; // 小写字母
  if (RegExp(r'\d').hasMatch(pwd)) categories++; // 数字
  if (RegExp(specialChars).hasMatch(pwd)) categories++; // 特殊字符

  return categories >= 3;
}

bool isValidUser(String user) {
  return RegExp(r"^[a-zA-Z][a-zA-Z0-9_\-@#*&!%]{4,59}").hasMatch(user);
}


String treeNodeKey(Int64 id) =>  "$id$innerNodeKey";


