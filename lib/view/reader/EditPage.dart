import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../model/reader_model.dart';
import '../../service/reader_service.dart';

class EditProfilePage extends StatefulWidget {
  late Reader reader;

  EditProfilePage({Key? key, required this.reader}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _sdtController;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reader.name);
    _emailController = TextEditingController(text: widget.reader.email);
    _sdtController = TextEditingController(text: widget.reader.phoneNumber);

    _nameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _sdtController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isChanged = _nameController.text != widget.reader.name ||
          _emailController.text != widget.reader.email ||
          _sdtController.text != widget.reader.phoneNumber;
    });
  }


  void _saveChanges() async {
    final updatedReader = Reader()
      ..id = widget.reader.id
      ..name = _nameController.text
      ..email = _emailController.text
      ..phoneNumber = _sdtController.text;

    // Cập nhật thông tin độc giả
    bool success = await updateReader(updatedReader);
    if (success) {
      Navigator.of(context).pop(updatedReader); // Trả về reader đã được cập nhật
    }
  }

  void _cancelChanges() {
    Navigator.of(context).pop(); // Quay lại trang trước mà không lưu thay đổi
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa Thông Tin'),
        actions: [
          TextButton(
            onPressed: _isChanged ? _saveChanges : null,
            child: Text(
              'Xác Nhận',
              style: TextStyle(color: _isChanged ? Colors.white : Colors.grey),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên độc giả'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _sdtController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _cancelChanges,
                  child: Text('Hủy'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: _isChanged ? _saveChanges : null,
                  child: Text('Xác Nhận'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
