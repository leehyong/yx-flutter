import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final defaultDtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final twoValidNumber = NumberFormat('0.##');

DateTime dtLocalFromMilliSecondsTimestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: false);

String localFromMicroSecondsTimestamp(int seconds) =>
    defaultDtFormat.format(dtLocalFromMilliSecondsTimestamp(seconds));

Future<DateTime> showCusDateTimePicker(
  BuildContext context, {
  DateTime? dt,
  TimeOfDay? td,
}) async {
  var fullDateTime = DateTime.now();
  DateTime date = await showCusDatePicker(context, dt: dt);
  if (context.mounted) {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: td ?? TimeOfDay.now(),
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
  final now = DateTime.now();
  return await showDatePicker(
        context: context,
        initialDate: dt ?? now,
        firstDate: now.subtract(Duration(days: 15)),
        lastDate: now.add(Duration(days: 365 * 5)),
      ) ??
      now;
}
