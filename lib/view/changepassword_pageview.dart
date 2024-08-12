import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:luanvan/config.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  ChangePasswordScreen({required this.email});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${ConFig.apiUrl}/user/change-password'), // Thay thế bằng URL API của bạn
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.email,
            'oldPassword': oldPasswordController.text,
            'newPassword': newPasswordController.text,
          }),
        );

        final responseData = jsonDecode(response.body);

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200 && responseData['success']) {
          oldPasswordController.clear();
          newPasswordController.clear();
          _showSuccessDialog();
        } else {
          _showErrorDialog(responseData['message'] ?? 'Failed to change password');
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('có lỗi xảy ra vui lòng thử lại.');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('mật khẩu đã được đổi thành công.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: oldPasswordController,
                decoration: InputDecoration(labelText: 'mật khẩu cũ'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'nhập mật khẩu cũ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'mật khẩu mới'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'nhập mật khẩu mới';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _changePassword,
                child: Text('đổi mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
