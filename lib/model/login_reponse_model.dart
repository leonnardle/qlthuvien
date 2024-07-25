import 'dart:convert';

LoginReponseModel loginReponseJson(String str) =>
    LoginReponseModel.fromJson(json.decode(str));

String loginReponseToJson(LoginReponseModel data) => json.encode(data.toJson());

class LoginReponseModel {
  bool? success;
  String? message;
  Data? data;

  LoginReponseModel({this.success, this.message, this.data});

  factory LoginReponseModel.fromJson(Map<String, dynamic> json) {
    return LoginReponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? email;
  String? password;

  Data({this.id, this.email, this.password});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }
}
