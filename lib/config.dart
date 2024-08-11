import 'package:flutter/foundation.dart' show kIsWeb;

String getApiUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000';
  } else {
    return 'http://192.168.1.17:3000';
  }
}
class ConFig{
  static const String appName="quan ly thu vien";
  static String get apiUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://192.168.1.17:3000';
    }
  }  static const String loginAPI="/user/login";
  static const String registerAPI="/user/register";
  static const String userProfileAPI="/user/user-profile";

}