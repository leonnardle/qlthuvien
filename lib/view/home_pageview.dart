import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:luanvan/service/api_service.dart';

import '../service/shared.dart';
import '../widget/navbar.dart';

class MyHomePage extends StatelessWidget {
  String name;
  MyHomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Quản Lý Thư Viện'),
        actions: [
          IconButton(
            onPressed: () {
            ShareService.logout(context);
          }, icon: const Icon(Icons.logout),
        )],
      ),
    );
  }
}