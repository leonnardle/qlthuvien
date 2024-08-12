import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luanvan/view/publisher/publisherAdd_pageview.dart';

import '../../model/publisher_model.dart';
import '../../service/publisher_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import '../../widget/navbar.dart';
import 'booklistByPublisher_pageview.dart';


class ListPublisher extends StatefulWidget {
  late Future<List<Publisher>>? items;

  ListPublisher({super.key, this.items});

  _ListPublisherState createState() => _ListPublisherState();
}

class _ListPublisherState extends State<ListPublisher> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Danh Sách nhà xuất bản'),
      ),
      body:FutureBuilder<List<Publisher>>(
      future: widget.items,
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return const CircularProgressIndicator();
        }else if(snapshot.hasError){
          return const Center(child: Text('co loi xay ra'),);
        }else if(!snapshot.hasData||snapshot.data!.isEmpty){
          return const Center(child: Text('khong co sach'),);
        }else{
          final publishers = snapshot.data!;
          return Stack(
        children: [
          Positioned.fill(
            top: 10,
            child:
              ListView.builder(
              itemCount: publishers.length,
              itemBuilder: (context, index) {
                Publisher publisher=publishers[index];
                   return GestureDetector(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nhà xuất bản ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('mã nxb : ${publisher.id}'),
                                SizedBox(height: 4),
                                Text('tên nxb : ${publisher.name}'),
                                SizedBox(height: 4),
                                Text('địa chỉ : ${publisher.address}'),
                                SizedBox(height: 4),
                                Text('sdt : ${publisher.phonenumber}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showEditDialog(context, publisher);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, (confirm) async {
                                if(confirm){
                                  bool response = await deletePublisher(publisher);
                                  if (response) {
                                    _refreshAuthors();
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublisherBooksPage(publisher: publisher),
                      ),
                    );

                  },
                );
              },
            ),
          ),
        ],
      );
    }}),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPublisher()),
          );
          if (result) {
            _refreshAuthors();
          }
        },
      ),

    );
  }
  void _refreshAuthors() {
    setState(() {
      widget.items = fetchPublisher(); // Cập nhật Future để lấy dữ liệu mới
    });
  }
  void _showEditDialog(BuildContext context, Publisher publisher) async {
    late TextEditingController tennxbController = TextEditingController(text: publisher.name);
    late TextEditingController diachiController = TextEditingController(text: publisher.address);
    late TextEditingController sdtController = TextEditingController(text: publisher.phonenumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa nxb'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tennxbController,
                decoration: InputDecoration(
                  labelText: 'Tên nxb',
                ),
              ),
              TextField(
                controller: diachiController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                ),
              ),
              TextField(
                controller: sdtController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11), // Giới hạn 11 ký tự
                ],
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
                final newName = tennxbController.text;
                final newAddress = diachiController.text;
                final newPhoneNumber = sdtController.text;

                // Cập nhật thông tin nhà xuất bản
                publisher.name = newName;
                publisher.address = newAddress;
                publisher.phonenumber = newPhoneNumber;
                try {
                  if(mounted) {
                    await updatePublisher(publisher);
                    Navigator.of(context).pop();
                    _refreshAuthors();
                  }
                }catch(error){
                  rethrow;
                }
              },
              child: Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }
}


