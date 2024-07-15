import 'package:flutter/material.dart';

import '../../model/booktype_model.dart';
import '../../service/booktype_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import '../../widget/navbar.dart';
import 'booktypeAdd_pageview.dart';

class ListBookType extends StatefulWidget {
  late List<BookType>? items;

  ListBookType({super.key, this.items});

  _ListBookTypeState createState() => _ListBookTypeState();
}

class _ListBookTypeState extends State<ListBookType> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Danh Sách Loại Sách'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Danh Sách Loại Sách',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.yellow[700],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 50,
            child: ListView.builder(
              itemCount: widget.items!.length,
              itemBuilder: (context, index) {
                BookType booktype = widget.items![index];
                return GestureDetector(
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loại Sách ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('mã loại : ${booktype.id}'),
                                SizedBox(height: 4),
                                Text('tên loại : ${booktype.name}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                             _showEditDialog(context, booktype);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, (confirm) async {
                                if(confirm){
                                  await deleteBooktype(widget.items![index]);
                                  BookType? book = widget.items?[index];
                                  if (book != null) {
                                    setState(() {
                                      widget.items?.removeAt(index);
                                    });
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {

                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: AddButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookType(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _showEditDialog(BuildContext context, BookType booktype) async{
    final TextEditingController tenloaisachController = TextEditingController(text: booktype.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa Loại Sách'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenloaisachController,
                decoration: InputDecoration(
                  labelText: 'Tên Loại Sách',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final newName = tenloaisachController.text;

                // Cập nhật tên loại sách
                booktype.name=newName;
                await updateBooktype(booktype);

                // Cập nhật danh sách loại sách
                List<BookType> bookList = await fetchBookType();
                setState(() {
                  widget.items = bookList;
                });

                Navigator.of(context).pop();
              },
              child: Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }
}


