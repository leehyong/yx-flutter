
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

void errIsLoadingData(){
  errToast("数据加载中，请稍后再试!");
}

void errToast(String msg){
  toastification.show(
    type: ToastificationType.error,
    title: Text(msg),
    autoCloseDuration: const Duration(seconds: 3),
  );
}

void okToast(String msg){
  toastification.show(
    type: ToastificationType.success,
    title: Text(msg),
    autoCloseDuration: const Duration(seconds: 3),
  );
}

void warnToast(String msg){
  toastification.show(
    type: ToastificationType.warning,
    title: Text(msg),
    autoCloseDuration: const Duration(seconds: 3),
  );
}