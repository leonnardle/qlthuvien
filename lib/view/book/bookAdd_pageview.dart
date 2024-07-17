import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/service/publisher_service.dart';
import 'package:luanvan/view/book/booklist_pageview.dart';
import '../../model/publisher_model.dart';
import '../../service/book_service.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<FormState> _addBookKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorIdController = TextEditingController();
  final TextEditingController _booktypeIdController = TextEditingController();
  final TextEditingController _describerController = TextEditingController();
  List<Publisher> _publishers = [];
  List<Publisher> _selectedPublishers = [];

  Image? _selectedImage;
  bool _isLoading = false; // Biến để theo dõi trạng thái tải

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
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
        _isLoading = true; // Bắt đầu tải
      });

      // Thông báo nếu chưa chọn nhà xuất bản
      if (_selectedPublishers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ít nhất một nhà xuất bản')),
        );
        setState(() {
          _isLoading = false; // Kết thúc tải
        });
        return;
      }

      final book = Book()
        ..id = _idController.text
        ..name = _nameController.text
        ..listPublisherIds = _selectedPublishers.map((p) => p.id).toList() // Cập nhật danh sách nhà xuất bản
        ..authorId = _authorIdController.text
        ..bookTypeId = _booktypeIdController.text
        ..description = _describerController.text;

      // Cập nhật ảnh cho sách
      if (_selectedImage != null) {
        book.image = _selectedImage;
        book.imageBase64 = await book.getImageBase64();
      }

      try {
        await insertBook(book);
        // Lắng nghe Stream và điều hướng tới ListBook
        final stream = fetchBooks(); // Lấy Stream từ fetchBooks
        stream.listen((list) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ListBook(items: list),
              ),
            );
          }
        });
      } catch (error) {
        print('Lỗi khi thêm sách: $error');
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
                  controller: _idController,
                  decoration: InputDecoration(labelText: 'Mã Sách'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mã sách không được để trống';
                    }
                    return null;
                  },
                ),
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
                TextFormField(
                  controller: _authorIdController,
                  decoration: InputDecoration(labelText: 'Mã Tác Giả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mã tác giả không được để trống';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _booktypeIdController,
                  decoration: InputDecoration(labelText: 'Mã Loại Sách'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mã loại sách không được để trống';
                    }
                    return null;
                  },
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
