import 'package:flutter/material.dart';
import 'package:luanvan/model/reader_model.dart';
import 'package:luanvan/service/reader_service.dart';
import 'package:luanvan/view/login_pageview.dart';
import 'package:luanvan/view/reader/readerAdd_pageview.dart';
import '../../model/booktype_model.dart';
import '../../service/booktype_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';

class ListReader extends StatefulWidget {
  late Future<List<Reader>>? readerFuture;

  ListReader({super.key, this.readerFuture});

  @override
  _ListBookTypeState createState() => _ListBookTypeState();
}

class _ListBookTypeState extends State<ListReader> {

  /* @override
  void initState() {
    super.initState();
    _booktypeFuture = fetchBookType();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách doc gia'),
      ),
      body: FutureBuilder<List<Reader>>(
          future: widget.readerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi khi tải doc gia: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có doc gia nao'));
            } else {
              final  readersList=snapshot.data!;
              return ListView.builder(
                itemCount: readersList.length,
                itemBuilder: (context, index) {
                  Reader reader = readersList[index];
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
                                    'doc gia ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('mã đọc giả : ${reader.id}'),
                                  SizedBox(height: 4),
                                  Text('tên đọc giả : ${reader.name}'),
                                  //SizedBox(height: 4),
                                  //Text('danh sách phiếu mượn : ${reader.loanId}'),
                                  SizedBox(height: 4),
                                  Text('email : ${reader.email}'),
                                  SizedBox(height: 4),
                                  Text('sdt : ${reader.phoneNumber}'),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showEditDialog(context, reader);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(context, (confirm) async {
                                      if (confirm) {
                                        bool result=await deleteReader(readersList[index]);
                                        if(result){
                                          _refreshData();
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
            MaterialPageRoute(builder: (context) => AddReader()),
          );
          if (result) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Reader reader) async {
    final TextEditingController tendocgiaController = TextEditingController(text: reader.name);
    final TextEditingController emailController = TextEditingController(text: reader.email);
    final TextEditingController sdtController = TextEditingController(text: reader.phoneNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa doc gia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tendocgiaController,
                decoration: InputDecoration(
                  labelText: 'Tên doc gia',
                ),
              ),
              TextField(
                controller: sdtController,
                decoration: InputDecoration(
                  labelText: 'sdt',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email',
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
                final newName = tendocgiaController.text;
                final newSdt = sdtController.text;
                final newEmail = emailController.text;

                // Cập nhật tên loại sách
                reader.name = newName;
                reader.email = newEmail;
                reader.phoneNumber = newSdt;

                await updateReader(reader);

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
      widget.readerFuture = fetchReader(); // Cập nhật Future để lấy dữ liệu mới
    });
  }

}
