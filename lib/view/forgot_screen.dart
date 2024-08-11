import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:luanvan/config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _sendResetEmail() async {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() {
        _message = 'Vui lòng nhập email.';
      });
      return;
    }
    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/user/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = 'Email đặt lại mật khẩu đã được gửi.';
      });
    } else {
      setState(() {
        _message = 'Có lỗi xảy ra: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quên Mật Khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendResetEmail,
              child: Text('Gửi Email Đặt Lại Mật Khẩu'),
            ),
            SizedBox(height: 16.0),
            Text(
              _message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
