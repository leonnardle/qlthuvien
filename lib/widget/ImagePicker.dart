import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  Future<Image?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      return Image.memory(imageBytes);
    }
    return null;
  }

  Future<String?> convertImageToBase64(Image image) async {
    final completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
        completer.complete(imageInfo.image);
      }),
    );

    final img = await completer.future;
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();
    return base64Encode(uint8List);
  }

  Future<Image?> convertBase64ToImage(String base64String) async {
    try {
      final imageBytes = base64Decode(base64String);
      return Image.memory(imageBytes);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }
}