import 'dart:convert';
import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_reponse_model.dart';

class ShareService {
  static Future<bool> isLogged() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        // Kiểm tra sự tồn tại của khóa 'login_detail' trong SharedPreferences
        return prefs.containsKey('login_detail');
      } else {
        return await APICacheManager().isAPICacheKeyExist("login_detail");
      }
    } catch (e) {
      return false;      print("Error checking cache key existence: $e");

    }
  }

  static Future<LoginReponseModel?> loginDetails() async {
    try {
      if (kIsWeb) {
        // lấy value tu json sau đó truyền vô LoginReponseModel.fromJson
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('login_detail')) {
          final cacheData = prefs.getString('login_detail')!;
          final decodedData = jsonDecode(cacheData) as Map<String, dynamic>;
          return LoginReponseModel.fromJson(decodedData);
        }
      } else {
        var isKeyExist = await APICacheManager().isAPICacheKeyExist("login_detail");
        if (isKeyExist) {
          var cacheData = await APICacheManager().getCacheData("login_detail");
          final decodedData = jsonDecode(cacheData.syncData) as Map<String, dynamic>;
          return LoginReponseModel.fromJson(decodedData); // Chuyển đổi JSON thành đối tượng
        }
      }
    } catch (e) {
      print("Error getting login details from cache: $e");
    }
    return null;
  }

  static Future<void> setLoginDetail(LoginReponseModel model) async {
    // Chuyển đổi đối tượng thành JSON
    // Lưu dữ liệu vào SharedPreferences
    // Lưu dữ liệu vào cache
    try {
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
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

      } else {
        await APICacheManager().deleteCache("login_detail"); // Xóa dữ liệu khỏi cache
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    } catch (e) {
      print("Error logging out and clearing cache: $e");
    }
  }
}
