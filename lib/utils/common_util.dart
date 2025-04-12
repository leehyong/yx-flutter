import 'package:intl/intl.dart';

final defaultDtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final twoValidNumber = NumberFormat('0.##');


DateTime dtLocalFromMilliSecondsTimestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: false);

String localFromMicroSecondsTimestamp(int seconds) =>
    defaultDtFormat.format(dtLocalFromMilliSecondsTimestamp(seconds));
