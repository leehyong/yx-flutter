import 'package:flutter_test/flutter_test.dart';
import 'package:yx/utils/common_util.dart';

void main() {
  String pwd = '';

  test("不足6个字符", () {
    pwd = 'ABCcd';
    assert(!isValidPwd(pwd));
  });

  test("含中文字符", () {
    pwd = 'ABCsda方法丰富';
    assert(!isValidPwd(pwd));
  });

  test("大小写", () {
    pwd = 'ABCcdfe';
    assert(!isValidPwd(pwd));
  });

  test("大写+数字", () {
    pwd = 'ABC123';
    assert(!isValidPwd(pwd));
  });

  test("小写+数字", () {
    pwd = 'cdfe554';
    assert(!isValidPwd(pwd));
  });

  test("大写+特殊字符", () {
    pwd = 'AB&C..@ABC[[]]!\\';
    assert(!isValidPwd(pwd));
  });

  test("小写+特殊字符", () {
    pwd = 'abc#`^!';
    assert(!isValidPwd(pwd));
  });

  test("数字+特殊字符", () {
    pwd = '98&7#:;!-_.';
    assert(!isValidPwd(pwd));
  });

  test("空白字符 1", () {
    pwd = '987 #:;!';
    assert(!isValidPwd(pwd));
  });

  test("空白字符 -t", () {
    pwd = '987\t#:;_!';
    assert(!isValidPwd(pwd));
  });


  test("大小写+数字", () {
    pwd = 'ABCcdfe2323';
    assert(isValidPwd(pwd));
  });

  test("大写+小写+数字+特殊字符", () {
    pwd = 'ABCmn123@@#';
    assert(isValidPwd(pwd));
  });

  test("小写+数字+特殊字符", () {
    pwd = 'cdfe554%^.&';
    assert(isValidPwd(pwd));
  });

  test("大写+数字+特殊字符", () {
    pwd = 'ABC6509###!';
    assert(isValidPwd(pwd));
  });

  test("大写+数字+特殊字符", () {
    pwd = 'OPOM987#:;!';
    assert(isValidPwd(pwd));
  });

  test("用户格式", (){
    assert(isValidUser("ABC123"));
    assert(isValidUser("admin"));
    assert(isValidUser("test1"));
    assert(isValidUser("test@11"));
    assert(isValidUser("test*&%11"));
    assert(isValidUser("Test*&%11"));
    assert(!isValidUser("[]Test*&%11"));
    assert(!isValidUser("@Test*&%11"));
    assert(!isValidUser("0Test*&%11"));
  });
}
