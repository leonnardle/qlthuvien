import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import '../model/publisher_model.dart';
import '../widget/ImagePicker.dart';  // Import model nhà xuất bản

class Book {
  String _id = '';
  String _name = '';
  String _description = '';
  Image? _image;
  String? _imageBase64;
  List<String> _listPublisherIds = [];
  List<Publisher> _publishersList = [];
  List<String> _listBookTypeIds = [];
  List<BookType> _bookTypeList = [];
  List<String> _listAuthorIds = [];
  List<Author> _authorList = [];
  int _trangthai = 1; // Thêm thuộc tính trạng thái
  ImagePickerHelper _imagePickerHelper = ImagePickerHelper(); // Khởi tạo một lần

  String get id => _id;
  set id(String value) => _id = value;

  String get name => _name;
  set name(String value) => _name = value;

  List<String> get listBookTypeIds => _listBookTypeIds;
  set listBookTypeIds(List<String> value) => _listBookTypeIds = value;

  List<String> get listAuthorIds => _listAuthorIds;
  set listAuthorIds(List<String> value) => _listAuthorIds = value;

  List<String> get listPublisherIds => _listPublisherIds;
  set listPublisherIds(List<String> value) => _listPublisherIds = value;

  String get description => _description;
  set description(String value) => _description = value;

  Image? get image => _image;
  set image(Image? value) => _image = value;

  String? get imageBase64 => _imageBase64;
  set imageBase64(String? value) => _imageBase64 = value;

  List<Publisher> get publishersList => _publishersList;
  set publishersList(List<Publisher> value) => _publishersList = value;

  List<BookType> get bookTypeList => _bookTypeList;
  set bookTypeList(List<BookType> value) => _bookTypeList = value;

  List<Author> get listauthor => _authorList;
  set listauthor(List<Author> value) => _authorList = value;

  int get trangthai => _trangthai;  // Getter cho trạng thái
  set trangthai(int value) => _trangthai = value;  // Setter cho trạng thái

  Book();

  factory Book.fromJson(Map<String, dynamic> data) {
    String? imageBase64;
    Image? image;

    if (data['hinhanh'] != null && data['hinhanh'] is String) {
      try {
        imageBase64 = data['hinhanh'];
        final imageBytes = base64Decode(imageBase64!);
        image = Image.memory(imageBytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }

    return Book()
      ..id = data['masach'] ?? ''
      ..name = data['tensach'] ?? ''
      ..description = data['mota'] ?? ''
      ..image = image
      ..imageBase64 = imageBase64
      ..trangthai = int.tryParse(data['trangthai'].toString()) ?? 1;
  }

  Future<void> pickImage() async {
    _image = await _imagePickerHelper .pickImageFromGallery();
    if (_image != null) {
      _imageBase64 = await getImageBase64();
    }
  }

  Future<String?> getImageBase64() async {
    if (_image != null) {
      return await _imagePickerHelper .convertImageToBase64(_image!);
    }
    return null;
  }
}
