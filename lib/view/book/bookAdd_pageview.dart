import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/service/author_service.dart';
import 'package:luanvan/service/booktype_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/service/publisher_service.dart';
import '../../model/publisher_model.dart';
import '../../service/book_service.dart';
class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<FormState> _addBookKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _describerController = TextEditingController();
  List<Publisher> _publishers = [];
  List<Publisher> _selectedPublishers = [];
  List<BookType> _bookType = [];
  List<BookType> _selectedBooktype = [];
  List<Author> _author = [];
  List<Author> _selectedAuthor = [];
  Image? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
    _fetchBookType();
    _fetchAuthor();
  }

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
  Future<void> _fetchBookType() async {
    try {
      final booktype = await fetchBookType();
      setState(() {
        _bookType = booktype;
      });
    } catch (error) {
      print('Lỗi khi nạp danh sách nhà xuất bản: $error');
    }
  }
  Future<void> _fetchAuthor() async {
    try {
      final author = await fetchAuthor();
      setState(() {
        _author = author;
      });
    } catch (error) {
      print('Lỗi khi nạp danh sách tac gia: $error');
    }
  }

  Future<void> _pickImage() async {
    final book = Book();
    await book.pickImage();
    setState(() {
      _selectedImage = book.image;
    });
  }

  Future<void> _saveBook() async {
    if (_addBookKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      if (_selectedPublishers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ít nhất một nhà xuất bản')),
        );
        setState(() {
          _isLoading = false; // Kết thúc tải
        });
        return;
      }
      if (_selectedBooktype.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ít nhất một loại sách')),
        );
        setState(() {
          _isLoading = false; // Kết thúc tải
        });
        return;
      }
      final book = Book()
        ..id = _idController.text
        ..name = _nameController.text
        ..listPublisherIds = _selectedPublishers.map((p) => p.id).toList() // Cập nhật danh sách ma nhà xuất bản
        ..listBookTypeIds = _selectedBooktype.map((p) => p.id).toList()
        ..listAuthorIds = _selectedAuthor.map((p) => p.id).toList()
        ..description = _describerController.text;

      if (_selectedImage != null) {
        book.image = _selectedImage;
        book.imageBase64 = await book.getImageBase64();
      }
      try {
        await insertBook(book);
        if(mounted) {
          Navigator.pop(context, true);
        }
      } catch (error) {
        if (kDebugMode) {
          print('Lỗi khi thêm sách: $error');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Kết thúc tải
          });
        }
      }
    }
  }
  void _selectPublishers() async {
    try {
       showDialog<List<Publisher>>(
        context: context,
        builder: (context) {
          return MultiSelectDialog(
            items: _publishers.map((p) => MultiSelectItem(p, p.name)).toList(),
            initialValue: _selectedPublishers,
            title: Text('Chọn Nhà Xuất Bản'),
            onConfirm: (values) {
              setState(() {
                _selectedPublishers = values;
              });
              Navigator.of(context).pop;  // Trả giá trị đã chọn về
            },
          );
        },
      );
/*
      if (selected != null) {
        setState(() {
          _selectedPublishers = selected;
        });
      }*/
    } catch (error) {
      print('Lỗi khi chọn nhà xuất bản: $error');
    }
  }
  void _selectBookType() async {
    try {
      showDialog<List<BookType>>(
        context: context,
        builder: (context) {
          return MultiSelectDialog(
            items: _bookType.map((p) => MultiSelectItem(p, p.name)).toList(),
            initialValue: _selectedBooktype,
            title: Text('Chọn ma loai'),
            onConfirm: (values) {
              setState(() {
                _selectedBooktype = values;
              });
              Navigator.of(context).pop;  // Trả giá trị đã chọn về
            },
          );
        },
      );
/*
      if (selected != null) {
        setState(() {
          _selectedPublishers = selected;
        });
      }*/
    } catch (error) {
      print('Lỗi khi chọn nhà xuất bản: $error');
    }
  }
  void _selectAuthor() async {
    try {
      showDialog<List<Author>>(
        context: context,
        builder: (context) {
          return MultiSelectDialog(
            items: _author.map((p) => MultiSelectItem(p, p.name)).toList(),
            initialValue: _selectedAuthor,
            title: Text('Chọn tac gia'),
            onConfirm: (values) {
              setState(() {
                _selectedAuthor = values;
              });
              Navigator.of(context).pop;  // Trả giá trị đã chọn về
            },
          );
        },
      );
/*
      if (selected != null) {
        setState(() {
          _selectedPublishers = selected;
        });
      }*/
    } catch (error) {
      print('Lỗi khi chọn tac gia: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Sách'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Hiển thị bộ nạp khi đang tải
          : SingleChildScrollView(  // Sử dụng SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _addBookKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Tên Sách'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên sách không được để trống';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _selectAuthor,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Chọn mã tác giả',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_selectedAuthor.isEmpty
                        ? 'Chưa chọn tác giả'
                        : _selectedAuthor.map((p) => p.name).join(', ')),
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _selectPublishers,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Chọn Nhà Xuất Bản',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_selectedPublishers.isEmpty
                        ? 'Chưa chọn nhà xuất bản'
                        : _selectedPublishers.map((p) => p.name).join(', ')),
                  ),
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _selectBookType,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Chọn ma loai',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_selectedBooktype.isEmpty
                        ? 'Chưa chọn ma loai'
                        : _selectedBooktype.map((p) => p.id).join(', ')),
                  ),
                ),
                TextFormField(
                  controller: _describerController,
                  decoration: InputDecoration(labelText: 'Mô Tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mô tả không được để trống';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _selectedImage == null
                    ? Text('Chưa chọn ảnh')
                    : Image(image: _selectedImage!.image, width: 100, height: 100, fit: BoxFit.cover),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Chọn Ảnh'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveBook,
                  child: Text('Lưu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
