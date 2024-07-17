import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luanvan/model/booktype_model.dart';
import '../model/publisher_model.dart';
import '../widget/ImagePicker.dart';  // Import model nhà xuất bản

class Book {
  String _id = '';
  String _name = '';
  String _authorId = '';
  String _description = '';
  int _quantity = 0;
  Image? _image;
  String? _imageBase64;
  List<String> _listPublisherIds = [];
  List<Publisher> _publishersList = [];
  List<String> _listBookTypeIds = [];
  List<BookType> _bookTypeList = [];

  String get id => _id;
  set id(String value) => _id = value;

  String get name => _name;
  set name(String value) => _name = value;

  String get authorId => _authorId;
  set authorId(String value) => _authorId = value;



  List<String> get listBookTypeIds => _listBookTypeIds;
  set listBookTypeIds(List<String> value) => _listBookTypeIds = value;

  List<String> get listPublisherIds => _listPublisherIds;
  set listPublisherIds(List<String> value) => _listPublisherIds = value;

  String get description => _description;
  set description(String value) => _description = value;

  int get quantity => _quantity;
  set quantity(int value) => _quantity = value;

  Image? get image => _image;
  set image(Image? value) => _image = value;

  String? get imageBase64 => _imageBase64;
  set imageBase64(String? value) => _imageBase64 = value;

  List<Publisher> get publishersList => _publishersList;  // Thêm getter và setter cho danh sách nhà xuất bản
  set publishersList(List<Publisher> value) => _publishersList = value;

  List<BookType> get bookTypeList => _bookTypeList;  // Thêm getter và setter cho danh sách nhà xuất bản
  set bookTypeList(List<BookType> value) => _bookTypeList = value;

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

    List<Publisher> publishersList = [];
    if (data['publishers'] != null) {
      publishersList = List<Publisher>.from(data['publishers'].map((x) => Publisher.fromJson(x)));
    }
    List<BookType> bookTypeList = [];
    if (data['booktype'] != null) {
      bookTypeList = List<BookType>.from(data['booktype'].map((x) => BookType.fromJson(x)));
    }
    return Book()
      ..id = data['masach'] ?? ''
      ..name = data['tensach'] ?? ''
      ..authorId = data['matg'] ?? ''
      ..bookTypeList = bookTypeList
      ..listPublisherIds = List<String>.from(data['manxbList'] ?? [])
      ..description = data['mota'] ?? ''
      ..quantity = data['soluong'] ?? 0
      ..image = image
      ..imageBase64 = imageBase64
      ..publishersList = publishersList
      ..listBookTypeIds = List<String>.from(data['manloaiList'] ?? [])
    ;  // Cập nhật ở đây
  }


  Future<void> pickImage() async {
    final imagePickerHelper = ImagePickerHelper();
    _image = await imagePickerHelper.pickImageFromGallery();
    if (_image != null) {
      _imageBase64 = await getImageBase64();
    }
  }

  Future<String?> getImageBase64() async {
    final imagePickerHelper = ImagePickerHelper();
    if (_image != null) {
      return await imagePickerHelper.convertImageToBase64(_image!);
    }
    return null;
  }
}
