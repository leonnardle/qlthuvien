import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/login_reponse_model.dart';
import 'package:luanvan/model/login_request_model.dart';
import 'package:luanvan/model/register_request_model.dart';
import 'package:luanvan/model/register_response_model.dart';
import 'package:luanvan/service/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  static var client = http.Client();

  static Future<LoginReponseModel> login(LoginRequestModel model) async {
    Map<String, String> requestHeader = {'Content-Type': 'application/json'};

    var response = await client.post(Uri.parse('${ConFig.apiUrl}/user/login'),
        headers: requestHeader, body: jsonEncode(model.toJson()));

    if (response.statusCode == 200) {
      await ShareService.setLoginDetail(loginReponseJson(response.body));
      return loginReponseJson(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<RegisterReponseModel> register(
      RegisterRequestModel model) async {
    Map<String, String> requestHeader = {'Content-Type': 'application/json'};
    var reponse = await client.post(Uri.parse('${ConFig.apiUrl}/user/register'),
        headers: requestHeader, body: jsonEncode(model.toJson()));
    return registerReponseModel(reponse.body);
  }
/*
  static Future<String> getUserProfile () async {
    Map<String,String> requestHeader={
      'Content-Type':'application/json'
    };
    var url=Uri.http(ConFig.apiUrl,ConFig.userProfileAPI);
    var reponse=await client.get(url,headers: requestHeader,);
    if(reponse.statusCode==200){
      return reponse.body;
    }else{
      return "";
    }
  }
*/
}
