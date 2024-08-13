import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/view/publisher/publisherList_pageview.dart';

import '../../function/checkValidate.dart';
import '../../model/publisher_model.dart';
import '../../service/publisher_service.dart';
import '../../widget/navbar.dart';
import '../../widget/textbutton.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
class AddPublisher extends StatefulWidget {
  AddPublisher({Key? key}) : super(key: key);
  _AddPublisherState createState() => _AddPublisherState();
}

class _AddPublisherState extends State<AddPublisher> {
  String? manxb;
  String? tennxb;
  String? diachi;
  String? sdt;
  final GlobalKey<FormState> PublisherAddFormKey = GlobalKey<FormState>();
  bool isAPIcallProcess = false;

  void addNhaxuatban() async {
    if (FormValidator.checkValidateAndSave(PublisherAddFormKey)) {
      Publisher publisher = Publisher()
        ..name = tennxb!
        ..address = diachi!
        ..phonenumber = sdt!;

      try {
       bool check= await insertPublisher(publisher);
       if(!check){
         return;
       }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Xử lý lỗi nếu có
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi thêm nhà xuất bản: $e')),
          );
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
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
            child:  Form(
              key: PublisherAddFormKey,
              child: _addPublisherUI(context),
            ),
          ),
        ));
  }

  Widget _addPublisherUI(BuildContext context){
    return Scaffold(
      //drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm nha xuat ban'),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ten nxb'),

                    FormHelper.inputFieldWidget(
                      context,
                      "tên nxb",
                      "tên nxb",
                          (onValiDate) {
                        if(onValiDate.isEmpty){
                          return('tên nxb không được trống');
                        }
                          },
                          (onSaved) {
                        tennxb = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      maxLength: 50,
                      borderRadius: 10,

                    ),
                    SizedBox(height: 10),
                    Text('dia chi'),

                    FormHelper.inputFieldWidget(
                      context,
                      "dia chi",
                      "dia chi",
                          (onValiDate) {
                            if(onValiDate.isEmpty){
                              return('địa chỉ không được trống');
                            }
                          },
                          (onSaved) {
                        diachi = onSaved;
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
                      " sdt",
                      "sdt",
                          (onValiDate) {
                            if(onValiDate.isEmpty){
                              return('sdt không được trống');
                            }else{
                              if(onValiDate.length != 11){
                                return "Số điện thoại phải có đúng 11 ký tự";
                              }
                              return null;
                            }
                          },
                          (onSaved) {
                        sdt = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10,
                      maxLength: 11,
                      isNumeric: true

                    ),
                    SizedBox(height: 10),
                    MyButton(onTap: addNhaxuatban, text: 'them nxb',),
                  ],
                ),
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
