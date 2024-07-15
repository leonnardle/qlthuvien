import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../widget/ImagePicker.dart';

class Author {
  String _id = '';
  String _name = '';
  String _country = '';
  String _story = '';
  String _email = '';
  Image? _image;
  String? _imageBase64;

  String get id => _id;
  set id(String value) => _id = value;

  String get name => _name;
  set name(String value) => _name = value;

  String get country => _country;
  set country(String value) => _country = value;

  String get story => _story;
  set story(String value) => _story = value;

  String get email => _email;
  set email(String value) => _email = value;

  Image? get image => _image;
  set image(Image? value) => _image = value;

  String? get imageBase64 => _imageBase64;
  set imageBase64(String? value) => _imageBase64 = value;

  Author();

  factory Author.fromJson(Map<String, dynamic> data) {
    Image? image;
    String? imageBase64;
    if (data['image'] != null && data['image'] is String) {
      try {
        imageBase64 = data['image'];
        final imageBytes = base64Decode(imageBase64!);
        image = Image.memory(imageBytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }

    return Author()
      ..id = data['matacgia'] ?? ''
      ..name = data['tentacgia'] ?? ''
      ..country = data['quoctich'] ?? ''
      ..story = data['tieusu'] ?? ''
      ..email = data['email'] ?? ''
      ..image = image
      ..imageBase64 = imageBase64;
  }

  Future<Map<String, dynamic>> toJson() async {
    final imagePickerHelper = ImagePickerHelper();
    if (_image != null) {
      _imageBase64 = await imagePickerHelper.convertImageToBase64(_image!);
    }

    return {
      'matacgia': _id,
      'tentacgia': _name,
      'quoctich': _country,
      'tieusu': _story,
      'email': _email,
      'image': _imageBase64,
    };
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
