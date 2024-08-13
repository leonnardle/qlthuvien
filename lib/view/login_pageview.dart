import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:luanvan/config.dart';
import 'package:luanvan/function/checkValidate.dart';
import 'package:luanvan/model/login_request_model.dart';
import 'package:luanvan/service/api_service.dart';
import 'package:luanvan/view/forgot_screen.dart';
import 'package:luanvan/view/home_pageview.dart';
import 'package:luanvan/view/reader_homepage.dart';
import 'package:luanvan/view/register_pageview.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? username;
  String? password;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: HexColor("#283B71"),
      body: ProgressHUD(
        child: Form(
          key: globalFormKey,
          child: _loginUI(context),
        ),
        key: UniqueKey(),
        inAsyncCall: isAPIcallProcess,
        opacity: 0.3,
      ),
    ));
  }

  Widget _loginUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Center(
              child: Image.asset(
                "assets/images/logo.jpg",
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 30, top: 100),
          ),
          FormHelper.inputFieldWidget(context, "username", "Username",
              (onValiDate) {
            if (onValiDate.isEmpty) {
              return ("username không được trống");
            }
          }, (onSaved) {
            username = onSaved;
          },
              initialValue: "trungquocle636@gmail.com",
              borderFocusColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white,
              borderRadius: 10,
              prefixIcon: const Icon(
                Icons.person,
              ),
              showPrefixIcon: true),
          FormHelper.inputFieldWidget(
            context,
            "password",
            "Password",
            (onValiDate) {
              if (onValiDate.isEmpty) {
                return ("password không được để trống");
              }
            },
            (onSaved) {
              password = onSaved;
            },
            initialValue: "00000000",
            borderFocusColor: Colors.white,
            borderColor: Colors.white,
            textColor: Colors.white,
            hintColor: Colors.white,
            borderRadius: 10,
            obscureText: hidePassword ? true : false,
            prefixIcon: const Icon(
              Icons.lock,
            ),
            showPrefixIcon: true,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              color: Colors.white,
              icon:
                  Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 10),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'quên mật khẩu?',
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));

                            }),
                    ]),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
              child: FormHelper.submitButton(
            "đăng nhập",
            () {
              if (FormValidator.checkValidateAndSave(globalFormKey)) {
                setState(() {
                  isAPIcallProcess = true;
                });

                LoginRequestModel model =
                    LoginRequestModel(email: username, password: password);

                APIService.login(model).then((response) {
                  setState(() {
                    isAPIcallProcess = false;
                  });

                  if (response != null) {
                    String role =
                        response.data?.role ?? ''; // Lấy role từ response.data
                    if (role == 'admin') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (route) => false, // Xóa tất cả các trang trước đó
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerHomePage()),
                        (route) => false,
                      );
                    }
                  }
                }).catchError((error) {
                  setState(() {
                    isAPIcallProcess = false;
                  });
                  FormHelper.showSimpleAlertDialog(
                    context,
                    ConFig.appName,
                    "Đã xảy ra lỗi: $error",
                    "OK",
                    () {
                      Navigator.pop(context);
                    },
                  );
                });
              }
            },
            btnColor: HexColor("#283B71"),
            borderRadius: 10,
            borderColor: Colors.white,
          )),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              'OR',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(text: 'không có tài khoản? '),
                    TextSpan(
                        text: 'đăng ký ',
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => RegisterPage(),) );
                          }),
                  ]),
            ),
          )
        ],
      ),
    );
  }
/*
  bool checkValidateAndSave(){
    final form=globalFormKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }
    return false;
  }
*/
}
