import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/function/checkValidate.dart';
import 'package:luanvan/model/book_model.dart';

import 'package:luanvan/service/loanSlip_service.dart';
import 'package:luanvan/service/reader_service.dart';

import '../../model/loanslip_model.dart';
import '../../service/book_service.dart';
import '../../widget/textbutton.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class AddLoanSlip extends StatefulWidget {
  AddLoanSlip({Key? key}) : super(key: key);
  _AddLoanSlipState createState() => _AddLoanSlipState();
}

class _AddLoanSlipState extends State<AddLoanSlip> {
  String? maphieumuon;
  String? madocgia;
  final GlobalKey<FormState> loanSlipAddFormKey = GlobalKey<FormState>();
  bool isAPIcallProcess = false;
  late TextEditingController _bookIdsController = TextEditingController();


  Future<void> _saveLoanSlip() async {
    if (FormValidator.checkValidateAndSave(loanSlipAddFormKey)) {
      List<String> validBookIds = [];
      List<String> invalidBooks = [];
      bool checkReader = await checkReaderExists(madocgia!);
      bool checkLoanId = await checkLoanSlipExists(maphieumuon!);


      if (checkReader && !checkLoanId) {
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
            LoanSlip loanSlip = LoanSlip()
              ..id = maphieumuon!
              ..readerId = madocgia!
              ..loanDay = DateTime.now()
              ..listBookIds = validBookIds;

            print("Valid Book IDs Length: ${validBookIds.length}");
            print("LoanSlip ListBookIds Length: ${loanSlip.listBookIds.length}");

            await insertLoanslip(loanSlip);
            if (mounted) {
              Navigator.pop(context, true);
            }
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
            const SnackBar(content: Text("Có lỗi xảy ra. Hãy kiểm tra mã phiếu mượn hoặc độc giả")),
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
              key: loanSlipAddFormKey,
              child: _addLoanSlipUI(context),
            ),
            key: UniqueKey(),
            inAsyncCall: isAPIcallProcess,
            opacity: 0.3,
          ),
        ));
  }

  Widget _addLoanSlipUI(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        title: Text('Thêm phieu muon'),
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
                  Text('mã phieu muon'),
                  FormHelper.inputFieldWidget(context, "mã phieu muon", "mã phieu muon",
                          (onValiDate) {
                        if (onValiDate.isEmpty) {
                          return ("mã phieu muon không được trống");
                        }
                      }, (onSaved) {
                        maphieumuon = onSaved;
                      },
                      borderFocusColor: Colors.white,
                      borderColor: Colors.white,
                      textColor: Colors.black,
                      hintColor: Colors.black,
                      borderRadius: 10),
                  SizedBox(height: 10),
                  Text('ma doc gia'),
                  FormHelper.inputFieldWidget(
                    context,
                    "ma doc gia",
                    "ma doc gia",
                        (onValiDate) {
                      if (onValiDate.isEmpty) {
                        return ("ma doc gia không được để trống");
                      }
                    },
                        (onSaved) {
                      madocgia = onSaved;
                    },
                    borderFocusColor: Colors.white,
                    borderColor: Colors.white,
                    textColor: Colors.black,
                    hintColor: Colors.black,
                    borderRadius: 10,
                    initialValue: "dg1"
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
                    initialValue: "6,f"
                  ),
                  SizedBox(height: 10),
                  MyButton(
                    onTap: _saveLoanSlip,
                    text: 'them phieu muon',
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
