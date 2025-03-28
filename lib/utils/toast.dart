
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

void errIsLoadingData(){
  toastification.show(
    type: ToastificationType.error,
    title: Text("数据加载中，请稍后再试!"),
    autoCloseDuration: const Duration(seconds: 3),
  );
}