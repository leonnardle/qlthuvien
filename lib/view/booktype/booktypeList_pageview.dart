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
  final TextEditingController _searchController = TextEditingController();
  List<BookType> _allBookTypes = [];
  List<BookType> _filteredBookTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchBookTypes();
    _searchController.addListener(() {
      _filterBookTypes();
    });
  }

  Future<void> _fetchBookTypes() async {
    try {
      final bookTypes = await fetchBookType();
      setState(() {
        _allBookTypes = bookTypes;
        _filteredBookTypes = bookTypes;
      });
    } catch (e) {
     // xu ly su kien neu loi
    }
  }

  void _filterBookTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookTypes = _allBookTypes.where((bookType) {
        final nameLower = bookType.name.toLowerCase();
        return nameLower.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Loại Sách'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300), // Optional: Constrain width
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<BookType>>(
        future: widget.bookTypeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải loại sách: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có loại sách'));
          } else {
            final bookTypesList = _filteredBookTypes.isNotEmpty
                ? _filteredBookTypes
                : snapshot.data!;
            return ListView.builder(
              itemCount: bookTypesList.length,
              itemBuilder: (context, index) {
                BookType bookType = bookTypesList[index];
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
                                  'Loại Sách ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Mã loại : ${bookType.id}'),
                                const SizedBox(height: 4),
                                Text('Tên loại : ${bookType.name}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showEditDialog(context, bookType);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, (confirm) async {
                                if (confirm) {
                                  await deleteBooktype(bookTypesList[index]);
                                  _fetchBookTypes(); // Cập nhật dữ liệu sau khi xóa
                                }
                              });
                            },
                            icon: const Icon(Icons.delete),
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
        },
      ),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookType()),
          );
          if (result) {
            _fetchBookTypes();
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, BookType bookType) async {
    final TextEditingController tenLoaiSachController =
    TextEditingController(text: bookType.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh Sửa Loại Sách'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenLoaiSachController,
                decoration: const InputDecoration(
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
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final newName = tenLoaiSachController.text;

                // Cập nhật tên loại sách
                bookType.name = newName;
                await updateBooktype(bookType);

                // Cập nhật danh sách loại sách
                _fetchBookTypes(); // Cập nhật dữ liệu sau khi chỉnh sửa

                Navigator.of(context).pop();
              },
              child: const Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }
}
