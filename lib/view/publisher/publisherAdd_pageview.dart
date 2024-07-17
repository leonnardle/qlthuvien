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

  void addNhaxuatban() async{
    if(FormValidator.checkValidateAndSave(PublisherAddFormKey)) {
      Publisher publisher = Publisher()..id=manxb!..name=tennxb!..address=diachi!..phonenumber=sdt!;
      await insertPublisher(publisher);
      List<Publisher> list=await fetchPublisher();
      Navigator.push(context, MaterialPageRoute(builder:(context)=> ListPublisher(items: list,)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: HexColor("#283B71"),
          body: ProgressHUD(
            child: Form(
              key: PublisherAddFormKey,
              child: _addPublisherUI(context),
            ),
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
          ),
        ));
  }

  Widget _addPublisherUI(BuildContext context){
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm Loại Sách'),
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
                    Text('mã nxb'),
                    FormHelper.inputFieldWidget(context, "mã nxb", "mã nxb",
                            (onValiDate) {
                          if (onValiDate.isEmpty) {
                            return ("mã nxb không được trống");
                          }
                        }, (onSaved) {
                          manxb = onSaved;
                        },
                        borderFocusColor: Colors.white,
                        borderColor: Colors.white,
                        textColor: Colors.black,
                        hintColor: Colors.black,
                        borderRadius: 10),

                    SizedBox(height: 10),
                    Text('ten nxb'),

                    FormHelper.inputFieldWidget(
                      context,
                      "tên nxb",
                      "tên nxb",
                          (onValiDate) {},
                          (onSaved) {
                        tennxb = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10,
                    ),
                    SizedBox(height: 10),
                    Text('dia chi'),

                    FormHelper.inputFieldWidget(
                      context,
                      "dia chi",
                      "dia chi",
                          (onValiDate) {},
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
                          (onValiDate) {},
                          (onSaved) {
                        sdt = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10,
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
