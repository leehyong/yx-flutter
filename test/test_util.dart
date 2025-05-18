import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx/utils/common_util.dart';

void main() {
  test("test dt1", ()  {
    final dt = parseDateFromStr("2025-05-20");
    assert(dt != null);
    assert(dt!.microsecondsSinceEpoch > 0);
    debugPrint(dt!.toIso8601String());
  });

  test("test dt2", ()  {
    final dt = parseDateFromStr("2025/05/20");
    assert(dt != null);
    assert(dt!.microsecondsSinceEpoch > 0);
    debugPrint(dt!.toIso8601String());
  });

}