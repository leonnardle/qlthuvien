import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/login_reponse_model.dart';
import 'package:luanvan/model/register_request_model.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import '../config.dart';
import '../model/login_request_model.dart';
import '../service/api_service.dart';
class RegisTerPage extends StatefulWidget {
  const RegisTerPage({super.key});

  @override
  State<RegisTerPage> createState() => _RegisTerPageState();
}

class _RegisTerPageState extends State<RegisTerPage> {
  @override
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
                              print('entered');
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
                "đăng ký",
                    () {
                  if(checkValidateAndSave()){
                    setState(() {
                      isAPIcallProcess=false;
                    });
                  }
                  RegisterRequestModel model=RegisterRequestModel(
                    email: username!,
                    password: password!
                  );

                  APIService.register(model).then((reponse) => {
                    if(reponse!=null){
                      FormHelper.showSimpleAlertDialog(
                          context, ConFig.appName, "dang ky thanh cong/hay dang nhap", "OK", (){
                        Navigator.pop(context);
                      }),
                      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false)
                    }else{
                      FormHelper.showSimpleAlertDialog(
                          context, ConFig.appName, "empty", "OK", (){
                        Navigator.pop(context);
                      })
                    }
                  });
                },
                btnColor: HexColor("#283B71"),
                borderRadius: 10,
                borderColor: Colors.white,
              )),


        ],
      ),
    );
  }
  bool checkValidateAndSave(){
    final form=globalFormKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }
    return false;
  }
}
