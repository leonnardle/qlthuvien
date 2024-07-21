import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/service/author_service.dart';
import 'package:luanvan/view/author/authorAdd_pageview.dart';
import '../../widget/ImagePicker.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import '../../widget/navbar.dart';

class ListAuthor extends StatefulWidget {
  late List<Author>? items;

  ListAuthor({Key? key, this.items}) : super(key: key);

  @override
  _ListAuthorState createState() => _ListAuthorState();
}

class _ListAuthorState extends State<ListAuthor> {
  late Future<List<Author>> _authorFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authorFuture = fetchAuthor();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        title: Text('Danh Sách Tác Giả'),
      ),
      body: FutureBuilder<List<Author>>(
        future: _authorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải sách: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sách'));
          } else {
            final authors = snapshot.data!;
            return Stack(
              children: [
                Positioned.fill(
                  top: 50,
                  child: ListView.builder(
                    itemCount: authors.length,
                    itemBuilder: (context, index) {
                      Author author = authors[index];
                      return GestureDetector(
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 120,
                                  child: author.imageBase64 != null && author.imageBase64!.isNotEmpty ? Image.memory(base64Decode(author.imageBase64!), fit: BoxFit.cover,)
                                      : const Icon(Icons.person, size: 80), // Placeholder nếu không có hình ảnh
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tác giả ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Mã tác giả : ${author.id}'),
                                      SizedBox(height: 4),
                                      Text('Tên tác giả : ${author.name}'),
                                      SizedBox(height: 4),
                                      Text('Quốc tịch : ${author.country}'),
                                      SizedBox(height: 4),
                                      Text('Tiểu sử : ${author.story}'),
                                      SizedBox(height: 4),
                                      Text('Email : ${author.email}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    // Xử lý sự kiện sửa tác giả
                                    _showEditDialog(context, author);
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Xử lý sự kiện xóa tác giả
                                    showDeleteConfirmationDialog(context,
                                        (confirm) async {
                                      if (confirm) {
                                        final response = await deleteAuthor(author);
                                        if (response) {
                                          _refreshAuthors();
                                        } else {
                                          print('đã xảy ra lỗi khi xóa tác giả với id : ${author.id}');
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
                          // Xử lý sự kiện khi nhấn vào một tác giả
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 60,
                  right: 30,
                  child: AddButton(
                    onPressed: () async{
                      // Thêm tác giả mới
                      bool result=await
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddAuthor()),
                      );
                      if(result){
                        _refreshAuthors();
                      }
                    },
                  ),
                ),
              ],

            );
          }
        },
      ),

    );
  }

  void _showEditDialog(BuildContext context, Author author) async {
    final TextEditingController nameController = TextEditingController(text: author.name);
    final TextEditingController countryController = TextEditingController(text: author.country);
    final TextEditingController storyController = TextEditingController(text: author.story);
    final TextEditingController emailController = TextEditingController(text: author.email);
    Image? selectedImage = author.image;
    bool isLoading = false;
    Future<void> pickImage(Function setState) async {
      Image? pickedImage = await ImagePickerHelper().pickImageFromGallery();
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Chỉnh Sửa tác giả'),
              content:
                  isLoading // khi StatefulBuilder không có trạng thái nào đang tải thì singechild sẽdduowdduo khởi tạo và dữ liệu được đổ vào
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên tác giả',
                                ),
                              ),
                              TextField(
                                controller: countryController,
                                decoration: InputDecoration(
                                  labelText: 'Quốc tịch',
                                ),
                              ),
                              TextField(
                                controller: storyController,
                                decoration: InputDecoration(
                                  labelText: 'tiểu sử',
                                ),
                              ),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'email',
                                ),
                              ),
                              SizedBox(height: 16.0),
                              selectedImage == null
                                  ? Text('Chưa chọn ảnh')
                                  : Image(
                                      image: selectedImage!.image,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () => pickImage(setState),
                                child: Text('Chọn Ảnh'),
                              ),
                            ],
                          ),
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
                    //isLoading là true , lúc này giao diện sẽ build lại
                    setState(() {
                      isLoading = true;
                    });

                    final newName = nameController.text;
                    final newCountry = countryController.text;
                    final newStory = storyController.text;
                    final newEmail = emailController.text;
                    // Cập nhật thông tin tác giả
                    author.name = newName;
                    author.country = newCountry;
                    author.story = newStory;
                    author.email = newEmail;
                    // Cập nhật ảnh cho tác giả
                    if (selectedImage != null) {
                      author.image = selectedImage;
                      author.imageBase64 = await author.getImageBase64();
                    }
                    await updateAuthor(author);
                    // Cập nhật danh sách tác giả
                    List<Author> authorList = await fetchAuthor();
                    setState(() {
                      widget.items = authorList;
                      isLoading = false;
                    });
                    Navigator.of(context).pop();
                    _refreshAuthors();
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
  void _refreshAuthors() {
    setState(() {
      _authorFuture = fetchAuthor(); // Cập nhật Future để lấy dữ liệu mới
    });
  }

}
