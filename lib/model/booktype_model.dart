import 'dart:ui';

class BookType {
  String _id = '';
  String _name = '';

  String get id => _id;
  set id(String value) {
    _id = value;
  }

  String get name => _name;
  set name(String value) {
    _name = value;
  }

  BookType();

  factory BookType.fromJson(Map<String, dynamic> data) {
    BookType bookType = BookType();
    bookType.id = data['maloai'] ?? '';
    bookType.name = data['tenloai'] ?? '';
    return bookType;
  }

  Map<String, dynamic> toJson() {
    return {
      'maloai': _id,
      'tenloai': _name,
    };
  }
}
