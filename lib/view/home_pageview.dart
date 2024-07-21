import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/service/api_service.dart';
import 'package:luanvan/view/author/authorList_pageview.dart';
import 'package:luanvan/view/publisher/publisherList_pageview.dart';

import '../service/book_service.dart';
import '../service/shared.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
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
              onItemSelected(FutureBuilder<List<Book>>(
                future: fetchBooks(),  // Tạo Future mới mỗi khi chọn
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error:  ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    Future<List<Book>> books = fetchBooks();
                    return ListBook(booksFuture: books);  // Truyền danh sách sách vào ListBook
                  } else {
                    return ListBook();  // Trường hợp không có dữ liệu
                  }
                },
              ));
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
              List<Author> list = await fetchAuthor();
              onItemSelected(ListAuthor(items: list));
            },
          ),
          ListTile(
            title: Text('Quản Lý Đọc Giả'),
            onTap: () async {},
          ),
          ListTile(
            title: Text('Quản Lý Phiếu Mượn'),
            onTap: () async {},
          ),
          ListTile(
            title: Text('Quản Lý Phiếu Trả'),
            onTap: () async {},
          ),
        ],
      ),
    );
  }
}
