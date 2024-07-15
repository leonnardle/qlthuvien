import 'dart:convert';

RegisterReponseModel registerReponseModel(String js) =>
    RegisterReponseModel.fromJson(json.decode(js));
class RegisterReponseModel {
  String? message;
  Data? data;

  RegisterReponseModel({this.message, this.data});

  RegisterReponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? email;
  String? password;
  String? id;

  Data({this.email, this.password, this.id});

  Data.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['password'] = this.password;
    data['id'] = this.id;
    return data;
  }
}