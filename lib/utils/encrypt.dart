import 'dart:convert';

import 'package:dart_sm/dart_sm.dart';

import '../config.dart';

String encrypt(List<int> txt, {String pubKey = publicKey}) {
  var data = base64Encode(txt);
  // var enc = SM2.encrypt(data, publicKey, cipherMode: C1C3C2);
  // return "04$enc";
  return SM2.encrypt(data, pubKey, cipherMode: C1C3C2);
}

String encryptWith04Prefix(List<int> txt, {String pubKey = publicKey}) =>
    "04${encrypt(txt, pubKey: pubKey)}";

String encryptYx(String txt) => encryptWith04Prefix(txt.codeUnits);
