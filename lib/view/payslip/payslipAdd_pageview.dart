import 'package:flutter/material.dart';
import 'package:luanvan/model/loanslip_model.dart';
import 'package:luanvan/model/payslip_model.dart';
import 'package:luanvan/service/loanSlip_service.dart';
import 'package:luanvan/service/payslip_service.dart'; // Thêm dịch vụ của bạn nếu cần

class AddReturnSlipFromLoanpage extends StatefulWidget {
  late LoanSlip? loanSlip;

  AddReturnSlipFromLoanpage({this.loanSlip});

  @override
  _AddReturnSlipState createState() => _AddReturnSlipState();
}

class _AddReturnSlipState extends State<AddReturnSlipFromLoanpage> {
  late TextEditingController _ghichuController = TextEditingController();
  late TextEditingController _maphieutraController = TextEditingController();
  late TextEditingController _sachController = TextEditingController(text: widget.loanSlip?.bookList.map((e) => e.id).join(', '));
  @override
  void initState() {
    super.initState();
  }

  Future<void> _savePaySlip() async {
    if (widget.loanSlip == null) return;
    List<String> loanBooks = widget.loanSlip!.bookList.map((e) => e.id.trim()).toList();
    print('Loan Books: $loanBooks');
    List<String> returnedBooks = _sachController.text
        .split(', ')
        .map((e) => e.trim()).where((e) => e.isNotEmpty) // Loại bỏ các giá trị rỗng
        .toList();
    print('Returned Books: $returnedBooks');

    // Xác định sách thiếu
    List<String> missingBooks = loanBooks.where((book) => !returnedBooks.contains(book)).toList();
    List<String> listBooks = loanBooks.where((book) => returnedBooks.contains(book)).toList();

    print('Missing Books: $missingBooks');
    print('List Books: $listBooks');

    // Kiểm tra ghi chú nếu có sách thiếu
    if (missingBooks.isNotEmpty && _ghichuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Những sách sau đây bị thiếu: ${missingBooks.join(', ')}\n'
            'Hãy thêm ghi chú.'),
      ));
      return;
    }

    PaySlip paySlip = PaySlip()
      ..payDay = DateTime.now()
      ..id = _maphieutraController.text
      ..loanId = widget.loanSlip!.id
      ..listBookIds = listBooks
      ..note = _ghichuController.text;


    // Thực hiện lưu phiếu trả
    bool result=await insertPaySlip(paySlip);
    if(!result&&mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('có lỗi xảy ra hoặc đã tồn tại phiếu trả cho phiếu mượn này')));
    }else {
      if(mounted) {
        Navigator.pop(context);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Trả sách cho phiếu mượn: ${widget.loanSlip!.id}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _maphieutraController,
          decoration: InputDecoration(
            labelText: 'Mã phiếu trả',
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _ghichuController,
          decoration: InputDecoration(
            labelText: 'Ghi chú',
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _sachController,
          decoration: InputDecoration(
            labelText: 'Sách thiếu',
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _savePaySlip,
          child: Text('Tạo Phiếu Trả'),
        ),
      ],
    );
  }
}
