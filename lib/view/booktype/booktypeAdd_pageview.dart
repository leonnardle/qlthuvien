import 'package:flutter/material.dart';
import 'package:luanvan/function/checkValidate.dart';

import '../../model/booktype_model.dart';
import '../../service/booktype_service.dart';
import '../../widget/textbutton.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class AddBookType extends StatefulWidget {
  AddBookType({Key? key}) : super(key: key);
  _AddBookTypeState createState() => _AddBookTypeState();
}

class _AddBookTypeState extends State<AddBookType> {
  String? maloai;
  String? tenloai;
  final GlobalKey<FormState> booktypeAddFormKey = GlobalKey<FormState>();
  bool isAPIcallProcess = false;

  void addLoaisach() async {
    if (FormValidator.checkValidateAndSave(booktypeAddFormKey)) {
      BookType bookType = BookType()
        ..id = maloai!
        ..name = tenloai!;
      await insertBooktype(bookType);
      if(mounted) {
        return;
      }else {
        Navigator.pop(context, true);
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
              key: booktypeAddFormKey,
              child: _addBooktypeUI(context),
            ),
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
          ),
        ));
  }

  Widget _addBooktypeUI(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm Loại Sách'),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 50),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('mã loại'),
                  FormHelper.inputFieldWidget(context, "mã loại", "mã loại",
                          (onValiDate) {
                        if (onValiDate.isEmpty) {
                          return ("mã loại không được trống");
                        }
                      }, (onSaved) {
                        maloai = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10),
                  SizedBox(height: 10),
                  Text('tên loại'),
                  FormHelper.inputFieldWidget(
                    context,
                    "tên loại",
                    "tên loại",
                        (onValiDate) {
                      if (onValiDate.isEmpty) {
                        return ("tên loại không được để trống");
                      }
                    },
                        (onSaved) {
                      tenloai = onSaved;
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  MyButton(
                    onTap: addLoaisach,
                    text: 'them loai sach',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Thêm Loại Sách',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.yellow[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
