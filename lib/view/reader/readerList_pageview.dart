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
  @override
  _ListReaderState createState() => _ListReaderState();
}

class _ListReaderState extends State<ListReader> {
  late TextEditingController _searchController = TextEditingController();
  List<Reader> _allReaders = [];
  List<Reader> _filteredReaders = [];

  @override
  void initState() {
    super.initState();
    _fetchReaders();
    _searchController.addListener(() {
      _filterReaders();
    });
  }

  Future<void> _fetchReaders() async {
    try {
      final readers = await fetchReader();
      setState(() {
        _allReaders = readers;
        _filteredReaders = readers;
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  void _filterReaders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReaders = _allReaders.where((reader) {
        final idLower = reader.id.toLowerCase();
        return idLower.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Độc Giả'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo mã...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Reader>>(
        future: fetchReader(), // Gọi lại hàm fetchReader mỗi khi cần
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải độc giả: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có độc giả nào'));
          } else {
            final readersList = _filteredReaders.isNotEmpty
                ? _filteredReaders
                : snapshot.data!;
            return ListView.builder(
              itemCount: readersList.length,
              itemBuilder: (context, index) {
                Reader reader = readersList[index];
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
                                  'Độc giả ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Mã đọc giả: ${reader.id}'),
                                SizedBox(height: 4),
                                Text('Tên đọc giả: ${reader.name}'),
                                SizedBox(height: 4),
                                Text('Email: ${reader.email}'),
                                SizedBox(height: 4),
                                Text('SDT: ${reader.phoneNumber}'),
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
                                  bool result = await deleteReader(reader);
                                  if (result) {
                                    _fetchReaders(); // Cập nhật danh sách sau khi xóa
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Không thể xóa độc giả.')),
                                    );
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                   // onTap: () {},
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReader()),
          );

          if (result != null && result == true) {
            _fetchReaders(); // Cập nhật danh sách sau khi thêm mới
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
          title: Text('Chỉnh Sửa Độc Giả'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tendocgiaController,
                decoration: InputDecoration(
                  labelText: 'Tên độc giả',
                ),
              ),
              TextField(
                controller: sdtController,
                decoration: InputDecoration(
                  labelText: 'SDT',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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

                // Cập nhật thông tin độc giả
                reader.name = newName;
                reader.email = newEmail;
                reader.phoneNumber = newSdt;

                await updateReader(reader);

                _fetchReaders(); // Cập nhật danh sách sau khi chỉnh sửa

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

