import 'package:flutter/material.dart';
import 'package:luanvan/view/login_pageview.dart';
import '../../model/booktype_model.dart';
import '../../service/booktype_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import 'booktypeAdd_pageview.dart';

class ListBookType extends StatefulWidget {
  late Future<List<BookType>>? bookTypeFuture;

  ListBookType({super.key, this.bookTypeFuture});

  @override
  _ListBookTypeState createState() => _ListBookTypeState();
}

class _ListBookTypeState extends State<ListBookType> {

 /* @override
  void initState() {
    super.initState();
    _booktypeFuture = fetchBookType();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Loại Sách'),
      ),
      body: FutureBuilder<List<BookType>>(
          future: widget.bookTypeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi khi tải sách: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có sách'));
            } else {
              final  booktypeslist=snapshot.data!;
              return ListView.builder(
                itemCount: booktypeslist.length,
                itemBuilder: (context, index) {
                  BookType booktype = booktypeslist[index];
                  return GestureDetector(
                    child: Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                showDeleteConfirmationDialog(context,
                                    (confirm) async {
                                  if (confirm) {
                                    await deleteBooktype(booktypeslist[index]);
                                    booktypeslist.removeAt(index);
                                    setState(
                                        () {}); // Cập nhật giao diện sau khi xóa
                                  }
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {},
                  );
                },
              );
            }
          }),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookType()),
          );
          if (result) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, BookType booktype) async {
    final TextEditingController tenloaisachController =
        TextEditingController(text: booktype.name);

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
                booktype.name = newName;
                await updateBooktype(booktype);

                // Cập nhật danh sách loại sách
                _refreshData(); // Cập nhật dữ liệu sau khi chỉnh sửa

                Navigator.of(context).pop();
              },
              child: Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }
  void _refreshData() {
    setState(() {
      widget.bookTypeFuture = fetchBookType(); // Cập nhật Future để lấy dữ liệu mới
    });
  }

}
