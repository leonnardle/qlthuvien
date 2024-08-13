import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/model/loanslip_model.dart';
import 'package:luanvan/model/payslip_model.dart';
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/model/reader_model.dart';
import 'package:luanvan/service/book_service.dart';
import 'package:luanvan/service/booktype_service.dart';
import 'package:luanvan/service/loanSlip_service.dart';
import 'package:luanvan/service/payslip_service.dart';
import 'package:luanvan/service/publisher_service.dart';
import 'package:luanvan/service/reader_service.dart';
import 'package:http/http.dart' as http;
import 'package:luanvan/view/author/authorList_pageview.dart';
import 'package:luanvan/view/loanslip/loanslipList_pageview.dart';
import 'package:luanvan/view/payslip/payslipList_pageview.dart';
import 'package:luanvan/view/publisher/publisherList_pageview.dart';
import 'package:luanvan/view/reader/readerList_pageview.dart';

import '../config.dart';
import '../service/shared.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/service/author_service.dart';
import 'package:badges/badges.dart' as badges;

import 'package:luanvan/view/booktype/booktypeList_pageview.dart';
import '../view/book/booklist_pageview.dart';
import 'PendingRequestsPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _content = Center(child: Text('Chọn một mục từ Menu'));

  void _setContent(Widget content) {
    setState(() {
      _content = content;
    });
  }

  int loanSlipCount = 0;
  // đếm số đơn mượn được gửi tới
  Future<int> fetchLoanSlipCount() async {
    final response = await http.get(Uri.parse('${ConFig.apiUrl}/phieumuondangchoduyet/count'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['count'];
    } else {
      throw Exception('lỗi khi nạp số lương phiếu');
    }
  }
  void _getLoanSlipCount() async {
    try {
      int count = await fetchLoanSlipCount();
      print("số lượng hien tại của phiếu mượn đang chờ là $count");

      setState(() {
        loanSlipCount = count;
      });
    } catch (e) {
      print('lỗi khi nạp số lương phiếu: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    _getLoanSlipCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        onItemSelected: (Widget content) {
          _setContent(content);
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        title: Text('Quản Lý Thư Viện'),
        actions: [
          IconButton(
            onPressed: () {
              ShareService.logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
          badges.Badge(
            badgeContent: Text(
              loanSlipCount.toString(),
              style: TextStyle(color: Colors.white),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 10),
            child: IconButton(
              onPressed: () {
                _getLoanSlipCount();
                _setContent(PendingRequestsPage(onUpdateLoanSlipCount:_getLoanSlipCount ,));
              },
              icon: const Icon(Icons.receipt),
            ),
          ),
        ],
      ),
      body: _content,
    );
  }
}
class NavBar extends StatelessWidget {
  final ValueChanged<Widget> onItemSelected;

  const NavBar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(
              'admin',
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              'trungquocle636@email.com',
              style: TextStyle(color: Colors.black),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Quản Lý Thông Tin Sách'),
            onTap: () {
              // Tạo Future mới mỗi khi chọn
              onItemSelected(ListBook());
            },
          ),
          ListTile(
            title: Text('Quản Lý Loại Sách'),
            onTap: () async {
              onItemSelected(ListBookType());
            },
          ),
          ListTile(
            title: Text('Quản Lý Nhà Xuất Bản'),
            onTap: () async {
              onItemSelected(ListPublisher());
            },
          ),
          ListTile(
            title: Text('Quản Lý Tác Giả'),
            onTap: () async {
              onItemSelected(ListAuthor());
            },
          ),
          ListTile(
            title: Text('Quản Lý Đọc Giả'),
            onTap: () async {
              //Future<List<Reader>> list =  fetchReader();
              onItemSelected(ListReader());
            },
          ),
          ListTile(
            title: Text('Quản Lý Phiếu Mượn'),
            onTap: () async {
              onItemSelected(ListLoanSlip());
            },
          ),
          ListTile(
            title: Text('Quản Lý Phiếu Trả'),
            onTap: () async {
              Future<List<PaySlip>> list =  fetchPaySlip();
              onItemSelected(ListPaySlip(PaySlipFuture: list));
            },
          ),
        ],
      ),
    );
  }
}
