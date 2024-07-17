import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/widget/deleteDialog.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import '../../model/book_model.dart';
import '../../model/publisher_model.dart';
import '../../service/book_service.dart';
import '../../service/publisher_service.dart';
import '../../widget/ImagePicker.dart';
import '../../widget/addButton.dart';
import '../../widget/navbar.dart';
import 'bookAdd_pageview.dart';

class ListBook extends StatefulWidget {
  final List<Book>? items;

  ListBook({Key? key, this.items}) : super(key: key);

  @override
  _ListBookState createState() => _ListBookState();
}

class _ListBookState extends State<ListBook> {
  late Stream<List<Book>> _booksStream;

  @override
  void initState() {
    super.initState();
    _booksStream = fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Danh Sách Sách'),
      ),
      body: StreamBuilder<List<Book>>(
        stream: _booksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải sách: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có sách'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Book book = books[index];
                return GestureDetector(
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 120,
                            child: book.imageBase64 != null && book.imageBase64!.isNotEmpty
                                ? Image.memory(
                              base64Decode(book.imageBase64!),
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.book, size: 80), // Placeholder nếu không có hình ảnh
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sách ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Mã sách : ${book.id}'),
                                SizedBox(height: 4),
                                Text('Tên sách : ${book.name}'),
                                SizedBox(height: 4),
                                Text('Mã tác giả : ${book.authorId}'),
                                SizedBox(height: 4),
                                Text('Mã loại sách : ${book.bookTypeId}'),
                                SizedBox(height: 4),
                                Text('Nhà xuất bản: ${book.publishersList.map((p) => p.name).join(', ')}'),  // Hiển thị tên nhà xuất bản
                                SizedBox(height: 4),
                                Text('Mô tả : ${book.description}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              // Xử lý sự kiện sửa sách
                              await _showEditDialog(context, book);
                              // Cập nhật lại dữ liệu khi quay lại màn hình danh sách sách
                              _refreshBooks();
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, (confirmed) async {
                                if (confirmed) {
                                  await deleteBook(book.id);
                                  // Cập nhật lại dữ liệu khi xóa sách
                                  _refreshBooks();
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
                    // Xử lý sự kiện khi nhấn vào một sách
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: AddButton(
        onPressed: () {
          // Thêm sách mới
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBook()),
          ).then((_) {
            // Cập nhật lại dữ liệu khi quay lại màn hình danh sách sách
            _refreshBooks();
          });
        },
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Book book) async {
    final TextEditingController nameController = TextEditingController(text: book.name);
    final TextEditingController authorIdController = TextEditingController(text: book.authorId);
    final TextEditingController bookTypeIdController = TextEditingController(text: book.bookTypeId);
    final TextEditingController descriptionController = TextEditingController(text: book.description);
    Image? selectedImage = book.image;
    bool isLoading = false;
    List<Publisher> _publishers = [];
    List<Publisher> _selectedPublishers = book.publishersList;

    Future<void> _fetchPublishers() async {
      try {
        final publishers = await fetchPublisher();
        setState(() {
          _publishers = publishers;
        });
      } catch (error) {
        print('Lỗi khi nạp danh sách nhà xuất bản: $error');
      }
    }

    Future<void> _pickImage(Function setState) async {
      Image? pickedImage = await ImagePickerHelper().pickImageFromGallery();
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }

    Future<void> _selectPublishers(BuildContext dialogContext, StateSetter setState) async {
      List<String> selectedPublisherIds = _selectedPublishers.map((p) => p.id).toList();

      await showDialog<List<Publisher>>(
        context: dialogContext,
        builder: (context) {
          return MultiSelectDialog(
            items: _publishers.map((p) => MultiSelectItem(p, p.name)).toList(),
            initialValue: _publishers.where((p) => selectedPublisherIds.contains(p.id)).toList(),
            title: Text('Chọn Nhà Xuất Bản'),
            onConfirm: (values) {
              setState(() {
                _selectedPublishers = values;
              });
            },
          );
        },
      );
    }

    await _fetchPublishers();

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Chỉnh Sửa Sách'),
              content: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên sách',
                      ),
                    ),
                    TextField(
                      controller: authorIdController,
                      decoration: InputDecoration(
                        labelText: 'Mã tác giả',
                      ),
                    ),
                    TextField(
                      controller: bookTypeIdController,
                      decoration: InputDecoration(
                        labelText: 'Mã loại sách',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () => _selectPublishers(dialogContext, setState),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Chọn Nhà Xuất Bản',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedPublishers.isEmpty
                              ? 'Chưa chọn nhà xuất bản'
                              : _selectedPublishers.map((p) => p.name).join(', '),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    selectedImage == null
                        ? Text('Chưa chọn ảnh')
                        : Image(image: selectedImage!.image, width: 100, height: 100, fit: BoxFit.cover),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _pickImage(setState),
                      child: Text('Chọn Ảnh'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    final newName = nameController.text;
                    final newAuthorId = authorIdController.text;
                    final newBookTypeId = bookTypeIdController.text;
                    final newDescription = descriptionController.text;

                    if (newName.isEmpty || newAuthorId.isEmpty || newBookTypeId.isEmpty || newDescription.isEmpty || _selectedPublishers.isEmpty) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
                      );
                      return;
                    }

                    book.name = newName;
                    book.authorId = newAuthorId;
                    book.bookTypeId = newBookTypeId;
                    book.description = newDescription;
                    book.publishersList = _selectedPublishers;

                    if (selectedImage != null) {
                      book.image = selectedImage;
                      book.imageBase64 = await book.getImageBase64();
                    }

                    final manxbList = _selectedPublishers.map((p) => p.id).toList();

                    try {
                      await updateBook(book, manxbList);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cập nhật sách thành công!')),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi cập nhật sách: $error')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pop(context);
                      _refreshBooks();  // Cập nhật dữ liệu khi hoàn thành chỉnh sửa sách
                    }
                  },
                  child: Text('Cập Nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _refreshBooks() {
    setState(() {
      _booksStream = fetchBooks();
    });
  }
}
