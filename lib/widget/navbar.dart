import 'package:flutter/material.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/service/author_service.dart';
import 'package:luanvan/service/book_service.dart';
import 'package:luanvan/service/booktype_service.dart';
import 'package:luanvan/service/publisher_service.dart';
import 'package:luanvan/view/booktype/booktypeList_pageview.dart';

import '../view/book/booklist_pageview.dart';


class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           const UserAccountsDrawerHeader(
            accountName: Text('admin',
              style: TextStyle(
                  color: Colors.black
              ),
            ),
            accountEmail: Text('trungquocle636@email.com',
              style: TextStyle(
                  color: Colors.black
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Quản Lý Thông Tin Sách'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamBuilder<List<Book>>(
                    stream: fetchBooks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error:  ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        List<Book> list = snapshot.data!;
                        return ListBook(items: list);
                      } else {
                        return ListBook();
                      }
                    },
                  ),
                ),
              );
            },
          ),

          ListTile(
            title: Text('Quản Lý Loại Sách'),
            onTap: () async {
              List<BookType> list=await fetchBookType();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/booktypelist',
                    (route) => false,  // Xóa tất cả các routes trước đó
                arguments: list,  // Truyền dữ liệu listBookType đến route mới
              );
            },          ),
          ListTile(
            title: Text('Quản Lý Nhân Viên'),
            onTap: ()async {
            },
          ),

          ListTile(
            title: Text('Quản Lý Nhà Xuất Bản'),
            onTap: ()async {
              List<Publisher> list=await fetchPublisher();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/publisherlist',
                    (route) => false,  // Xóa tất cả các routes trước đó
                arguments: list,  // Truyền dữ liệu listBookType đến route mới
              );
            },          ),
          ListTile(
            title: Text('Quản Lý Tác Giả'),
            onTap: ()async {
              List<Author> list=await fetchAuthor();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/authorlist',
                    (route) => false,
                arguments: list,
              );
            },          ),

          ListTile(
            title: Text('Quản Lý Sách Mượn'),
            onTap: ()async {
            },          ),
          ListTile(
            title: Text('Quản Lý Đọc Giả'),
            onTap: ()async {
            },          ),
          ListTile(
            title: Text('Quản Lý Phiếu Mượn'),
            onTap: ()async {
            },          ),
          ListTile(
            title: Text('Quản Lý Phiếu Trả'),
            onTap: ()async {
            },          ),
        ],
      ),
    );
  }
}