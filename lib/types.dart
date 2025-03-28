import 'package:flutter/material.dart';

enum DataLoadingStatus{
  none,
  loading,
  loaded
}

// class
//
typedef ResponseHandler = String Function();

const userCaptchaCode = 0;
const phoneCaptchaCode = 1;
const emailCaptchaCode = 2;

const loadingColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

const userStorage = "user-info";
const accessStorageKey = "accessToken";
const refreshStorageKey = "refreshToken";
const userStorageKey = "user";