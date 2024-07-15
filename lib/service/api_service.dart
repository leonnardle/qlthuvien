import 'dart:convert';

import 'package:http/http.dart'as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/login_reponse_model.dart';
import 'package:luanvan/model/login_request_model.dart';
import 'package:luanvan/model/register_request_model.dart';
import 'package:luanvan/model/register_response_model.dart';
import 'package:luanvan/service/shared.dart';
class APIService{
  static var client=http.Client();
  static Future<bool> login(LoginRequestModel model) async {
    Map<String,String> requestHeader={
      'Content-Type':'application/json'
    };
    var url = Uri.parse('${ConFig.apiUrl}${ConFig.loginAPI}');
    var reponse=await client.post(url,headers: requestHeader,body: jsonEncode(model.toJson()));
    if(reponse.statusCode==200){
      await ShareService.setLoginDetail(LoginreponseJson(reponse.body));
      return true;
    }else{
      return false;
    }
  }
  static Future<RegisterReponseModel> register(RegisterRequestModel model) async {
    Map<String,String> requestHeader={
      'Content-Type':'application/json'
    };
    var url=Uri.http(ConFig.apiUrl,ConFig.registerAPI);
    var reponse=await client.post(url,headers: requestHeader,body: jsonEncode(model.toJson()));
    return registerReponseModel(reponse.body);
  }
  static Future<String> getUserProfile () async {
    var loginDetail=await ShareService.loginDetails();
    Map<String,String> requestHeader={
      'Content-Type':'application/json',
      'Authorization':'Basic ${loginDetail!.data?[0].token}'
    };
    var url=Uri.http(ConFig.apiUrl,ConFig.userProfileAPI);
    var reponse=await client.get(url,headers: requestHeader,);
    if(reponse.statusCode==200){
      return reponse.body;
    }else{
      return "";
    }
  }

}