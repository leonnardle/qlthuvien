import 'package:flutter/material.dart';
import 'package:luanvan/view/author/authorList_pageview.dart';
import '../../model/author_model.dart';
import '../../service/author_service.dart';

class AddAuthor extends StatefulWidget {
  @override
  _AddAuthorState createState() => _AddAuthorState();
}

class _AddAuthorState extends State<AddAuthor> {
  final _addAuthorKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Image? _selectedImage;
  bool _isLoading = false; // Biến để theo dõi trạng thái tải

  Future<void> _pickImage() async {
    final author = Author();
    await author.pickImage();
    setState(() {
      _selectedImage = author.image;
    });
  }

  Future<void> _saveAuthor() async {
    if (_addAuthorKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final author = Author()
        ..name = _nameController.text
        ..country = _countryController.text
        ..story = _storyController.text
        ..email = _emailController.text;
      // Cập nhật ảnh cho tác giả
      if (_selectedImage != null) {
        author.image = _selectedImage;
        author.imageBase64 = await author.getImageBase64();
      }
      try{
        await insertAuthor(author);
        if(mounted) {
          Navigator.pop(context, true);
        }
      }catch(error){

      }finally{
        if(mounted){
          setState(() {
            _isLoading=false;
          });
        }
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Tác Giả'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Hiển thị bộ nạp khi đang tải
          : SingleChildScrollView(  // Sử dụng SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _addAuthorKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Tên Tác Giả',),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên tác giả không được để trống';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(labelText: 'Quốc Tịch'),
                  validator: (value) {

                    return null;
                  },
                  maxLength: 56,
                ),
                TextFormField(
                  controller: _storyController,
                  decoration: InputDecoration(labelText: 'Tiểu Sử'),
                  validator: (value) {
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isNotEmpty ) {
                      if(!value!.contains('@')) {
                        return 'Email không hợp lệ';
                      }
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
                TextButton(onPressed: _saveAuthor, child: const Text('Lưu'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
