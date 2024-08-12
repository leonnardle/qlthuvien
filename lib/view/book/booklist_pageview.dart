import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/service/booktype_service.dart';
import 'package:luanvan/widget/deleteDialog.dart';
import '../../model/book_model.dart';
import '../../model/publisher_model.dart';
import '../../service/author_service.dart';
import '../../service/book_service.dart';
import '../../service/publisher_service.dart';
import '../../widget/ImagePicker.dart';
import '../../widget/addButton.dart';
import '../../widget/navbar.dart';
import 'bookAdd_pageview.dart';

class ListBook extends StatefulWidget {

  ListBook({Key? key,}) : super(key: key);

  @override
  _ListBookState createState() => _ListBookState();
}
class _ListBookState extends State<ListBook> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBookTypes = [];
  List<Book> _filteredBook = [];
  void _refreshBooks() async {
    try {
      final bookTypes = await fetchBooks();
      setState(() {
        _allBookTypes = bookTypes;
        _filteredBook = _searchController.text.isEmpty
            ? bookTypes
            : bookTypes.where((bookType) {
          final nameLower = bookType.name.toLowerCase();
          return nameLower.contains(_searchController.text.toLowerCase());
        }).toList();
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  // cái này dùng để cập nhật danh sách khi thêm để đồng bộ với sách trong list để thực hiện chức năng tìm kiếm
  void _filterBook() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBook = _allBookTypes.where((bookType) {
        final nameLower = bookType.id.toLowerCase();
        return nameLower.contains(query);
      }).toList();
    });
  }  // dung de nap danh sach lan dau khi tai len
  Future<void> _fetchBook() async {
    try {
      final bookTypes = await fetchBooks();
      setState(() {
        _allBookTypes = bookTypes;
        _filteredBook = bookTypes;
      });
    } catch (e) {
      // Xu ly su kien neu loi
    }
  }
  @override

  void initState() {
    super.initState();
    //_booksFuture = widget.booksFuture ?? fetchBooks();
    _fetchBook();
    _searchController.addListener(() {
      _filterBook();
    });
    /*Timer.periodic(const Duration(minutes: 10), (timer) async {
      try {
        var books = await fetchBooks();
        if (mounted) {
          setState(() {
            _booksFuture = Future.value(books);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('du lieu da duoc cap nhat')));
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi nạp danh sách sách: $e');
        }
      }
    });*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Sách'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300), // Optional: Constrain width
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo tên loại...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],

      ),
      body: FutureBuilder<List<Book>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải sách: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sách'));
          } else {
            final books = _filteredBook.isNotEmpty
                ? _filteredBook
                : snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Book book = books[index];
                return GestureDetector(

                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                : const Icon(Icons.book, size: 80),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sách ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Mã sách: ${book.id}'),
                                Text('Tên sách: ${book.name}'),
                                Text('Mã tác giả: ${book.listauthor.map((p)=>p.id).join(', ')}'),
                                Text('Mã loại sách: ${book.bookTypeList.map((p) => p.id).join(', ')}'),
                                Text('Nhà xuất bản: ${book.publishersList.map((p) => p.id).join(', ')}'),
                                Text('Mô tả: ${book.description}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: ()  {

                              _showEditDialog(context, book);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              showDeleteConfirmationDialog(context, (confirmed) async {
                                if (confirmed) {
                                  bool result = await deleteBook(book.id);
                                  if (result) {
                                    await _fetchBook();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa sách thành công!')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể xóa, sách đã tồn tại trong 1 phiếu mượn')));
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
                    // Xử lý sự kiện khi nhấn vào sách
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: AddButton(
        onPressed: () async{
          bool result=await
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AddBook()),
          );
          if(result){
            _refreshBooks();
          }else{
            print('có lỗi khi thêm sách');
          }
        },
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Book book) async {
    final TextEditingController nameController = TextEditingController(text: book.name);
    final TextEditingController descriptionController = TextEditingController(text: book.description);
    Image? selectedImage = book.image;
    bool isLoading = false;
    List<Publisher> publishers0 = [];
    List<Publisher> selectedPublishers = book.publishersList;
    List<BookType> bookType0 = [];
    List<BookType> selectedBooktype = book.bookTypeList;
    List<Author> author0 = [];
    List<Author> selectedAuthor = book.listauthor;

    Future<void> _fetchPublishers() async {
      try {
        final publishers = await fetchPublisher();
        publishers0 = publishers; // Không cần setState ở đây
      } catch (error) {
        print('Lỗi khi nạp danh sách nhà xuất bản: $error');
      }
    }

    Future<void> _fetchBookTypes() async {
      try {
        final bookType = await fetchBookType();
        bookType0 = bookType; // Không cần setState ở đây
      } catch (error) {
        print('Lỗi khi nạp danh sách loại sách: $error');
      }
    }

    Future<void> _fetchAuthors() async {
      try {
        final author = await fetchAuthor();
        author0 = author; // Không cần setState ở đây
      } catch (error) {
        print('Lỗi khi nạp danh sách tác giả: $error');
      }
    }

    Future<void> pickImage(Function setState) async {
      Image? pickedImage = await ImagePickerHelper().pickImageFromGallery();
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }

    Future<void> selectPublishers(BuildContext dialogContext, StateSetter setState) async {
      List<String> selectedPublisherIds = selectedPublishers.map((p) => p.id).toList();
      await showDialog<List<Publisher>>(
        context: dialogContext,
        builder: (context) {
          return MultiSelectDialog(
            items: publishers0.map((p) => MultiSelectItem(p, p.name)).toList(),
            initialValue: publishers0.where((p) => selectedPublisherIds.contains(p.id)).toList(),
            title: const Text('Chọn Nhà Xuất Bản'),
            onConfirm: (values) {
              setState(() {
                selectedPublishers = values;
              });
            },
          );
        },
      );
    }

    Future<void> selectBookTypes(BuildContext dialogContext, StateSetter setState) async {
      List<String> selectedBookTypes = selectedBooktype.map((p) => p.id).toList();
      await showDialog<List<BookType>>(
        context: dialogContext,
        builder: (context) {
          return MultiSelectDialog(
            items: bookType0.map((p) => MultiSelectItem(p, p.id)).toList(),
            initialValue: bookType0.where((p) => selectedBookTypes.contains(p.id)).toList(),
            title: const Text('Chọn Mã Loại'),
            onConfirm: (values) {
              setState(() {
                selectedBooktype = values;
              });
            },
          );
        },
      );
    }

    Future<void> selectAuthors(BuildContext dialogContext, StateSetter setState) async {
      List<String> selectedAuthors = selectedAuthor.map((p) => p.id).toList();
      await showDialog<List<Author>>(
        context: dialogContext,
        builder: (context) {
          return MultiSelectDialog(
            items: author0.map((p) => MultiSelectItem(p, p.id)).toList(),
            initialValue: author0.where((p) => selectedAuthors.contains(p.id)).toList(),
            title: const Text('Chọn Mã Tác Giả'),
            onConfirm: (values) {
              setState(() {
                selectedAuthor = values;
              });
            },
          );
        },
      );
    }

    try {
      await Future.wait([
        _fetchPublishers(),
        _fetchBookTypes(),
        _fetchAuthors(),
      ]);

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Chỉnh Sửa Sách'),
                content: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên sách',
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => selectPublishers(dialogContext, setState),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Chọn Nhà Xuất Bản',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedPublishers.isEmpty
                                ? 'Chưa chọn nhà xuất bản'
                                : selectedPublishers.map((p) => p.name).join(', '),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => selectBookTypes(dialogContext, setState),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Chọn Mã Loại',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedBooktype.isEmpty
                                ? 'Chưa chọn mã loại'
                                : selectedBooktype.map((p) => p.id).join(', '),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => selectAuthors(dialogContext, setState),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Chọn Mã Tác Giả',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedAuthor.isEmpty
                                ? 'Chưa chọn mã tác giả'
                                : selectedAuthor.map((p) => p.id).join(', '),
                          ),
                        ),
                      ),
                      selectedImage == null
                          ? const Text('Chưa chọn ảnh')
                          : Image(image: selectedImage!.image, width: 100, height: 100, fit: BoxFit.cover),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => pickImage(setState),
                        child: const Text('Chọn Ảnh'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      final newName = nameController.text;
                      final newDescription = descriptionController.text;

                      if (newName.isEmpty || newDescription.isEmpty || selectedPublishers.isEmpty || selectedBooktype.isEmpty) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
                        );
                        return;
                      }
                      book.name = newName;
                      book.description = newDescription;

                      if (selectedImage != null) {
                        book.image = selectedImage;
                        book.imageBase64 = await book.getImageBase64();
                      }

                      final manxbList = selectedPublishers.map((p) => p.id).toList();
                      final maloaiList = selectedBooktype.map((p) => p.id).toList();
                      final matacgiaList = selectedAuthor.map((p) => p.id).toList();

                      try {
                        await updateBook(book, manxbList, maloaiList, matacgiaList);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cập nhật sách thành công!')),
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
                        _refreshBooks();
                      }
                    },
                    child: const Text('Cập Nhật'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      print(error);
    }
  }
  }