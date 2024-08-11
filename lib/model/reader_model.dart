import 'dart:ui';

class Reader {
  String _id = '';
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  List<String> _listLoanIds = [];
  //List<Publisher> _publishersList = [];


  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Reader();

  String get name => _name;

  set name(String value) {
    _name = value;
  }
  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String value) {
    _phoneNumber = value;
  }
  factory Reader.fromJson(Map<String, dynamic> data) {
    Reader bookType = Reader();
    bookType.id = data['madocgia'] ?? '';
    bookType.name = data['tendocgia'] ?? '';
    bookType.email = data['email'] ?? '';
    bookType.phoneNumber = data['sdt'] ?? '';

    return bookType;
  }

  Map<String, dynamic> toJson() {
    return {
      'madocgia': _id,
      'tendocgia': _name,
      'email': _email,
      'sdt': _phoneNumber,
    };
  }
}
