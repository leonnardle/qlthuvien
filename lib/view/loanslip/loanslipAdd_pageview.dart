import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/config.dart';
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

      if (checkReader) {
        setState(() {
          isAPIcallProcess = true;
        });

        // thêm dấu , để tách scsh rồi xóa khoảng trắng
        List<String> bookIds = _bookIdsController.text.split(',').map((line) => line.trim()).toList();
        bookIds.removeWhere((id) => id.isEmpty);

        try {
          // Kiểm tra sự tồn tại của sách
          List<Future<bool>> checkExistenceFutures = bookIds.map((id) => checkBookExists(id)).toList();
          List<bool> existResults = await Future.wait(checkExistenceFutures);

          // Phân loại ID sách hợp lệ và không hợp lệ
          bookIds.asMap().forEach((index, id) {
            if (existResults[index]) {
              validBookIds.add(id);
            } else {
              invalidBooks.add(id);
            }
          });

          // Kiểm tra sách không tồn tại
          if (invalidBooks.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Những sách sau không tồn tại: ${invalidBooks.join(', ')}'),
            ));
          } else {
            // Kiểm tra phiếu mượn chưa trả
            final response = await http.get(Uri.parse('http://192.168.1.17:3000/phieumuon/check/$madocgia'));

            if (response.statusCode == 200) {
              final List<dynamic> data = json.decode(response.body);

              if (data.isNotEmpty) {
                // Hiện dialog nếu có phiếu mượn chưa trả
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Có phiếu mượn chưa trả'),
                      content: Text('Độc giả này có phiếu mượn chưa trả. Bạn có muốn tiếp tục không?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                          },
                          child: Text('Không'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Đóng dialog
                            // Tiến hành thêm phiếu mượn
                            LoanSlip loanSlip = LoanSlip()
                              ..readerId = madocgia!
                              ..loanDay = DateTime.now()
                              ..listBookIds = validBookIds;

                            await insertLoanslip(loanSlip);
                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Text('Có'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Không có phiếu mượn chưa trả, tiến hành thêm phiếu mượn
                LoanSlip loanSlip = LoanSlip()
                  ..readerId = madocgia!
                  ..loanDay = DateTime.now()
                  ..listBookIds = validBookIds;

                await insertLoanslip(loanSlip);
                if (mounted) {
                  Navigator.pop(context, true);
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã xảy ra lỗi khi kiểm tra phiếu mượn.'),
              ));
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
         /*         Text('mã phieu muon'),
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
                      borderRadius: 10),*/
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
