import 'package:luanvan/model/book_model.dart';
import 'package:intl/intl.dart'; // Để sử dụng định dạng ngày tháng

class LoanSlip {
  String _id = '';
  String _readerId = '';
  bool _status = false;
  DateTime _loanDay = DateTime.now();
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

  String get readerId => _readerId;

  set readerId(String value) {
    _readerId = value;
  }

  bool get status => _status;

  set status(bool value) {
    _status = value;
  }

  DateTime get loanDay => _loanDay;

  set loanDay(DateTime value) {
    _loanDay = value;
  }

  List<Book> get bookList => _bookList;

  set bookList(List<Book> value) {
    _bookList = value;
  }

  LoanSlip();

  factory LoanSlip.fromJson(Map<String, dynamic> data) {
    LoanSlip loanSlip = LoanSlip();

    loanSlip.id = data['mapm'] ?? '';
    loanSlip.readerId = data['madocgia'] ?? '';

    // Chuyển đổi chuỗi ngày tháng thành đối tượng DateTime
    String? dateString = data['ngaymuon'];
    if (dateString != null && dateString.isNotEmpty) {
      loanSlip.loanDay = DateTime.parse(dateString);
    } else {
      loanSlip.loanDay = DateTime.now();
    }

    loanSlip.status = data['trangthai'] == 1 ? true : false;
    return loanSlip;
  }

  @override
  String toString() {
    return 'LoanSlip{_id: $_id, _readerId: $_readerId, _status: $_status, _loanDay: $_loanDay, _listBookIds: $_listBookIds, _bookList: $_bookList}';
  }
}
