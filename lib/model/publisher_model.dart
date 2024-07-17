
import 'book_model.dart';

class Publisher{
  String _id = '';
  String _name = '';
  String _address = '';
  String _phonenumber = '';


  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get name => _name;

  String get phonenumber => _phonenumber;

  set phonenumber(String value) {
    _phonenumber = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  set name(String value) {
    _name = value;
  }
  Publisher();

  factory Publisher.fromJson(Map<String, dynamic> data) {
    Publisher publisher = Publisher();
    publisher.id = data['manxb'] ?? '';
    publisher.name = data['tennxb'] ?? '';
    publisher.address = data['diachi'] ?? '';
    publisher.phonenumber = data['sdt'] ?? '';

    return publisher;
  }

  Map<String, dynamic> toJson() {
    return {
      'manxb': _id,
      'tennxb': _name,
      'diachi': _address,
      'sdt': _phonenumber
    };
  }
}