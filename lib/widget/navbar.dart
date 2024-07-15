import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/service/author_service.dart';
import 'package:luanvan/service/booktype_service.dart';
import 'package:luanvan/view/booktype/booktypeList_pageview.dart';


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
            onTap: ()async {
            },         ),
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