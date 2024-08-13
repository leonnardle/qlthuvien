import 'dart:convert';
import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/view/login_pageview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_reponse_model.dart';
import '../model/reader_model.dart';

class ShareService {
  static Future<bool> isLogged() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey('login_detail');
      } else {
        return await APICacheManager().isAPICacheKeyExist("login_detail");
      }
    } catch (e) {
      print("Error checking cache key existence: $e");
      return false;

    }
  }

  // lấy thông tin chi tiết của người dùng khi đăng nhập
  static Future<LoginReponseModel?> loginDetails() async {
    try {
      if (kIsWeb) {
        // lấy value tu json sau đó truyền vô LoginReponseModel.fromJson
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('login_detail')) {
          final cacheData = prefs.getString('login_detail')!;
          final decodedData = jsonDecode(cacheData) as Map<String, dynamic>;
          print('Decoded data: $decodedData');

          return LoginReponseModel.fromJson(decodedData);
        }
      } else {
        var isKeyExist = await APICacheManager().isAPICacheKeyExist("login_detail");
        if (isKeyExist) {
          var cacheData = await APICacheManager().getCacheData("login_detail");
          final decodedData = jsonDecode(cacheData.syncData) as Map<String, dynamic>;
          print('Decoded data: $decodedData');
          return LoginReponseModel.fromJson(decodedData); // Chuyển đổi JSON thành đối tượng
        }
      }
    } catch (e) {
      print("Error getting login details from cache: $e");
    }
    return null;
  }
  // tạo cache login_detail ể lưu thoogn tin dang nhap
  static Future<void> setLoginDetail(LoginReponseModel model) async {

    try {
      // lấy data=>tạo key rồi chuyểndatdataa vô (phương thức setString)=>add cache
      final data = loginReponseToJson(model);
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('login_detail', data);
      } else {
        APICacheDBModel cacheDbModel = APICacheDBModel(
            key: 'login_detail', syncData: data
        );
        await APICacheManager().addCacheData(cacheDbModel);
      }
    } catch (e) {
      print("Error setting login details to cache: $e");
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('login_detail'); // Xóa dữ liệu khỏi SharedPreferences
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
      } else {
        await APICacheManager().deleteCache("login_detail"); // Xóa dữ liệu khỏi cache
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
      }
    } catch (e) {
      print("Error logging out and clearing cache: $e");
    }
  }
}
void getReaderDetail(Function(Reader?) onReaderRetrieved) async {
  try {
    LoginReponseModel? loginResponse = await ShareService.loginDetails();

    if (loginResponse != null && loginResponse.data != null) {
      Reader? reader = loginResponse.data!.reader;
      onReaderRetrieved(reader);
    } else {
      print('No user is logged in');
      onReaderRetrieved(null); //  trả về null nếu không có người dùng đăng nhập
    }
  } catch (e) {
    print("Error retrieving login details: $e");
    onReaderRetrieved(null); // Trả về null trong trường hợp lỗi
  }
}

