import 'package:flutter/material.dart';
import 'package:luanvan/view/login_pageview.dart';
import '../../model/booktype_model.dart';
import '../../service/booktype_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import 'booktypeAdd_pageview.dart';

class ListBookType extends StatefulWidget {
  const ListBookType({super.key});

  @override
  _ListBookTypeState createState() => _ListBookTypeState();
}

class _ListBookTypeState extends State<ListBookType> {
  List<BookType> _bookTypes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _bookTypes = await fetchBookType();
    setState(() {});
  }
  void _refreshData() async {
    await _loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Loại Sách'),
      ),
      body: _bookTypes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(
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
              itemCount: _bookTypes.length,
              itemBuilder: (context, index) {
                BookType booktype = _bookTypes[index];
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
                                if (confirm) {
                                  await deleteBooktype(_bookTypes[index]);
                                  _bookTypes.removeAt(index);
                                  setState(() {}); // Cập nhật giao diện sau khi xóa
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
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: AddButton(
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookType(),
                  ),
                );
                if (result == true) {
                  _refreshData(); // Cập nhật dữ liệu khi quay lại
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, BookType booktype) async {
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
}
