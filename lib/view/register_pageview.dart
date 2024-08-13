import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import 'login_pageview.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;
    String phone = _phoneController.text;

    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'tendocgia': name,
        'sdt': phone,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success']) {
        // Reset các ô nhập liệu
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _phoneController.clear();

        // Hiển thị dialog thông báo
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Đăng Ký Thành Công'),
              content: Text(responseBody['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                    // Điều hướng đến trang đăng nhập
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      }
    } else {
      // Hiển thị thông báo lỗi kết nối
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối đến server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Ký Tài Khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên độc giả'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
              maxLength: 11,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Đăng Ký'),
            ),
          ],
        ),
      ),
    );
  }
}
