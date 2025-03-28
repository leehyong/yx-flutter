// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dart_sm/dart_sm.dart';
import 'package:yx/utils/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('dart_sm2 encrypt', () {
    KeyPair keypair = SM2.generateKeyPair();
    String privateKey = keypair.privateKey; // 私钥
    String publicKey = keypair.publicKey; // 公钥
    print(publicKey);
    String data = "2223333";
    // 默认C1C3C2格式
    String cipherText = SM2.encrypt(data, publicKey);
    String plainText = SM2.decrypt(cipherText, privateKey);
    expect(plainText, plainText);
// C1C2C3格式
    cipherText = SM2.encrypt(data, publicKey, cipherMode: C1C2C3);
    plainText = SM2.decrypt(cipherText, privateKey, cipherMode: C1C2C3);
    expect(plainText, plainText);
  });

  test('dart_sm2 encrypt2', (){
    encrypt("112233".codeUnits);
  });
}
