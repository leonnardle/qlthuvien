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

import 'package:luanvan/view/author/authorList_pageview.dart';
import 'package:luanvan/view/loanslip/loanslipList_pageview.dart';
import 'package:luanvan/view/payslip/payslipList_pageview.dart';
import 'package:luanvan/view/publisher/publisherList_pageview.dart';
import 'package:luanvan/view/reader/readerList_pageview.dart';

import '../service/shared.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/service/author_service.dart';

import 'package:luanvan/view/booktype/booktypeList_pageview.dart';
import '../view/book/booklist_pageview.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        onItemSelected: (Widget content) {
          _setContent(content);
          Navigator.pop(context); // Đóng Drawer sau khi chọn
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
          )
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
              Future<List<Book>> booksFuture = fetchBooks();
              onItemSelected(FutureBuilder<List<Book>>(
                future: booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else{
                    return ListBook(booksFuture: booksFuture,);
                  }
                },
              ));
            },
          ),
          ListTile(
            title: Text('Quản Lý Loại Sách'),
            onTap: () async {
              Future<List<BookType>> bookstypeFuture = fetchBookType();
              onItemSelected(ListBookType(bookTypeFuture: bookstypeFuture,));
            },
          ),
          ListTile(
            title: Text('Quản Lý Nhà Xuất Bản'),
            onTap: () async {
              Future<List<Publisher>> publisherlist = fetchPublisher();
              onItemSelected(ListPublisher(items: publisherlist,));
            },
          ),
          ListTile(
            title: Text('Quản Lý Tác Giả'),
            onTap: () async {
              Future<List<Author>> list =  fetchAuthor();
              onItemSelected(ListAuthor(items: list));
            },
          ),
          ListTile(
            title: Text('Quản Lý Đọc Giả'),
            onTap: () async {
              Future<List<Reader>> list =  fetchReader();
              onItemSelected(ListReader(readerFuture: list));
            },
          ),
          ListTile(
            title: Text('Quản Lý Phiếu Mượn'),
            onTap: () async {
              Future<List<LoanSlip>> list =  fetchLoanslip();
              onItemSelected(ListLoanSlip(LoanSlipFuture: list));
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
