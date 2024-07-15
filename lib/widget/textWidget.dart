import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  late bool obScureText = false;
  final String? hinText;

  MyTextField(
      {super.key, this.controller, this.hinText, required this.obScureText, required String hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obScureText,
      decoration: InputDecoration(
        hintText: hinText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
