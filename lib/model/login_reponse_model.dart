import 'dart:convert';

import 'package:luanvan/model/reader_model.dart';

// Hàm để giải mã JSON thành đối tượng LoginReponseModel
LoginReponseModel loginReponseJson(String str) =>
    LoginReponseModel.fromJson(json.decode(str));

// Hàm để mã hóa đối tượng LoginReponseModel thành JSON
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
  String? role;
  Reader? reader;

  Data({this.id, this.email, this.password, this.role, this.reader});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      // Gán giá trị cho role
      reader: json['reader'] != null
          ? Reader.fromJson(json['reader'])
          : null, // Gán giá trị cho reader
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['role'] = this.role; // Thêm role vào JSON
    if (this.reader != null) {
      data['reader'] = this.reader!.toJson(); // Chuyển đổi reader thành JSON
    }
    return data;
  }
}
