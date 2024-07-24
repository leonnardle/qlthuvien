
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/payslip_model.dart';
import 'package:luanvan/service/payslip_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import '../../function/checkValidate.dart';
import '../../service/book_service.dart';
import '../../service/loanSlip_service.dart';
import '../../widget/textbutton.dart';

class AddPaySlip extends StatefulWidget {
  AddPaySlip({Key? key}) : super(key: key);
  _AddPaySlipState createState() => _AddPaySlipState();
}

class _AddPaySlipState extends State<AddPaySlip> {
  String? maphieutra;
  String? maphieumuon;
  String? madocgia;
  String? ghichu;
  final GlobalKey<FormState> paySlipAddFormKey = GlobalKey<FormState>();
  bool isAPIcallProcess = false;
  late TextEditingController _bookIdsController = TextEditingController();

  Future<void> _saveLoanSlip() async {
    if (FormValidator.checkValidateAndSave(paySlipAddFormKey)) {
      List<String> validBookIds = [];
      List<String> invalidBooks = [];
      bool checkLoanId = await checkLoanSlipExists(maphieumuon!);


      if (checkLoanId ) {
        setState(() {
          isAPIcallProcess = true;
        });

        //print("Book IDs text: ${_bookIdsController.text}");
        List<String> bookIds = _bookIdsController.text.split(',').map((line) => line.trim()).toList();
        // print("Book IDs list: $bookIds");
        bookIds.removeWhere((id) => id.isEmpty);
        //print("Book IDs list after removing empty entries: $bookIds");

        try {
          List<Future<bool>> checkExistenceFutures = bookIds.map((id) => checkBookExists(id)).toList();
          List<bool> existResults = await Future.wait(checkExistenceFutures);

          bookIds.asMap().forEach((index, id) {
            if (existResults[index]) {
              validBookIds.add(id);
            } else {
              invalidBooks.add(id);
            }
          });

          if (invalidBooks.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Những sách sau không tồn tại: ${invalidBooks.join(', ')}'),
            ));
          } else {
            PaySlip loanSlip = PaySlip()
              ..id = maphieutra!
              ..loanId = maphieumuon!
              ..payDay = DateTime.now()
              ..listBookIds = validBookIds
            ..note=ghichu!;
            bool result=await insertPaySlip(loanSlip);
            if(!result&&mounted){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ma phieu muon da ton tai cho phieu tra nay')));
            }else{
            if (mounted) {
              Navigator.pop(context, true);
            }}
          }
        } catch (error) {
          if (kDebugMode) {
            print("Đã xảy ra lỗi khi thêm phiếu mượn: $error");
          }
        } finally {
          if (mounted) {
            setState(() {
              isAPIcallProcess = false;
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Có lỗi xảy ra. phieu muon khong ton tai")),
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
            child: Form(
              key: paySlipAddFormKey,
              child: _addLoanSlipUI(context),
            ),
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
          ),
        ));
  }

  Widget _addLoanSlipUI(BuildContext context) {
    return
      Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm phieu tra'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('mã phieu tra'),
                  FormHelper.inputFieldWidget(context, "mã phieu tra", "mã phieu tra",
                          (onValiDate) {
                        if (onValiDate.isEmpty) {
                          return ("mã phieu tra không được trống");
                        }
                      }, (onSaved) {
                        maphieutra = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10),
                  SizedBox(height: 10),
                  Text('ma phieu muon'),
                  FormHelper.inputFieldWidget(
                      context,
                      "ma phieu muon",
                      "ma phieu muon",
                          (onValiDate) {
                        if (onValiDate.isEmpty) {
                          return ("ma phieu muon không được để trống");
                        }
                      },
                          (onSaved) {
                        maphieumuon = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  Text('ma sach'),
                  FormHelper.inputFieldWidget(
                      context,
                      "ma sach",
                      "ma sach",
                          (onValiDate) {
                        if (onValiDate.isEmpty) {
                          return ("vui long nhap ma sach");
                        }
                      },
                          (onSaved) {
                        _bookIdsController.text = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  Text('ghi chu'),
                  FormHelper.inputFieldWidget(
                    context,
                    "ghi chu",
                    "ghi chu",
                        (onValiDate) {

                    },
                        (onSaved) {
                      ghichu = onSaved;
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                  ),
                  SizedBox(height: 10),
                  MyButton(
                    onTap: _saveLoanSlip,
                    text: 'them phieu tra',
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
                'Thêm phieu tra',
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
