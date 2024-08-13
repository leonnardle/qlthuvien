import 'package:luanvan/model/book_model.dart';
import 'package:intl/intl.dart'; // Để sử dụng định dạng ngày tháng

class PaySlip {
  String _id = '';
  String _loanId = '';
  bool _status = false;
  String _note = '';
  DateTime _payDay = DateTime.now();
  List<String> _listBookIds = [];
  List<Book> _bookList = [];

  List<String> get listBookIds => _listBookIds;

  set listBookIds(List<String> value) {
    _listBookIds = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get note => _note;

  set note(String value) {
    _note = value;
  }

  String get loanId => _loanId;

  set loanId(String value) {
    _loanId = value;
  }

  bool get status => _status;

  set status(bool value) {
    _status = value;
  }

  DateTime get payDay => _payDay;

  set payDay(DateTime value) {
    _payDay = value;
  }

  List<Book> get bookList => _bookList;

  set bookList(List<Book> value) {
    _bookList = value;
  }

  PaySlip();

  factory PaySlip.fromJson(Map<String, dynamic> data) {
    PaySlip loanSlip = PaySlip();

    loanSlip.id = data['mapt'] ?? '';
    loanSlip.loanId = data['maphieumuon'] ?? '';

    // Chuyển đổi chuỗi ngày tháng thành đối tượng DateTime
    String? dateString = data['ngaytra'];
    if (dateString != null && dateString.isNotEmpty) {
      loanSlip.payDay = DateTime.parse(dateString);
    } else {
      loanSlip.payDay = DateTime.now();
    }

    loanSlip.status = data['trangthai'] == 1 ? true : false;
    loanSlip.note = data['ghichu'] ?? '';

    return loanSlip;
  }
}
