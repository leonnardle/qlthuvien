import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/function/checkValidate.dart';

import '../../model/reader_model.dart';
import '../../service/reader_service.dart';
import '../../widget/textbutton.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class AddReader extends StatefulWidget {
  AddReader({Key? key}) : super(key: key);
  _AddReaderState createState() => _AddReaderState();
}

class _AddReaderState extends State<AddReader> {
  String? madocgia;
  String? tendocgia;
  String? email;
  String? sdt;
  final GlobalKey<FormState> readerAddFormKey = GlobalKey<FormState>();
  bool isAPIcallProcess = false;

  Future<void> _saveReader() async {
    if (FormValidator.checkValidateAndSave(readerAddFormKey)) {
      setState(() {
        isAPIcallProcess=true;
      });
      Reader reader = Reader()
        ..name = tendocgia!
        ..email=email!
        ..phoneNumber=sdt!;

      try {
        bool check=await insertReader(reader);
        if(check){
          if(mounted) {
          Navigator.pop(context, true);
         }
        }else{
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('đã có email tồn tại cho đọc giả này')));;
          }
        }
      }catch(error){
        if(kDebugMode){
          print("da xay ra loi khi them loai sach : $error");
        }
      }finally{
        if(mounted){
          if(mounted) {
            setState(() {
              isAPIcallProcess = false;
            });
          }
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: HexColor("#283B71"),
          body: ProgressHUD(
            child: Form(
              key: readerAddFormKey,
              child: _addReaderUI(context),
            ),
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
          ),
        ));
  }

  Widget _addReaderUI(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm doc gia'),
      ),
      body: isAPIcallProcess? const Center(child: CircularProgressIndicator()): Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 50),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(child:
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('tên doc gia'),
                  FormHelper.inputFieldWidget(
                    context,
                    "tên doc gia",
                    "tên doc gia",
                        (onValiDate) {
                      if (onValiDate.isEmpty) {
                        return ("tên doc gia không được để trống");
                      }
                    },
                        (onSaved) {
                      tendocgia = onSaved;
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  Text('email'),
                  FormHelper.inputFieldWidget(
                    context,
                    "email",
                    "email",
                        (onValiDate) {
                          if (onValiDate!.isNotEmpty ) {
                            if(!onValiDate!.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                          }else{
                            return 'email không được để trống';
                          }
                    },
                        (onSaved) {
                      email = onSaved;
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  Text('sdt'),
                  FormHelper.inputFieldWidget(
                    context,
                    "sdt",
                    "sdt",
                        (onValiDate) {
                      if (onValiDate.isEmpty) {
                        return 'Số điện thoại không được trống';
                      } else if (onValiDate.length != 11) {
                        return "Số điện thoại phải có đúng 11 ký tự";
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(onValiDate)) {
                        // Kiểm tra xem chuỗi chỉ chứa số
                        return "Số điện thoại chỉ được chứa chữ số";
                      }
                      return null; // Không có lỗi
                    },
                        (onSaved) {
                      sdt = onSaved; // Lưu giá trị khi form được lưu
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                    maxLength: 11,
                  ),
                  SizedBox(height: 10),
                  MyButton(
                    onTap: _saveReader,
                    text: 'them doc gia',
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
