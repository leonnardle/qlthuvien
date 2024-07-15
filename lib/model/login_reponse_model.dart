import 'dart:convert';

LoginReponseModel LoginreponseJson(String str) =>
    LoginReponseModel.fromJson(json.decode(str));

String loginReponseToJson(LoginReponseModel data) => json.encode(data.toJson());

class LoginReponseModel {
  bool? success;
  String? message;
  List<Data>? data;

  LoginReponseModel({this.success, this.message, this.data});

  LoginReponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? email;
  String? password;
  String? token;

  Data({this.id, this.email, this.password, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['token'] = this.token;
    return data;
  }
}
