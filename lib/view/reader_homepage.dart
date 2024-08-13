import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/service/book_service.dart';
import 'package:luanvan/service/shared.dart';
import 'package:luanvan/view/getListLoanFromReaderPage.dart';
import 'package:luanvan/view/reader/EditPage.dart';

import '../model/reader_model.dart';
import 'changepassword_pageview.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 0});
}

class CustomerHomePage extends StatefulWidget {
   CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  late Future<List<Book>> booksFuture;
  List<CartItem> cart = []; // Giỏ hàng
  Reader? currentReader;
  bool loading = false; // Biến theo dõi trạng thái tải lại
  List<Book> _availableBooks = []; // Biến lưu trữ sách có sẵn

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
    getReaderDetail((reader) {
      setState(() {
        currentReader = reader; // Cập nhật currentReader và gọi setState
      });
    });
  }

  void _addToCart(Book book) {
    final existingItem = cart.firstWhere(
      (item) => item.book.id == book.id,
      orElse: () => CartItem(book: book, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      existingItem.quantity = 1;
      cart.add(existingItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.name} đã được thêm vào giỏ hàng')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${book.name} đã có trong giỏ hàng, không thể thêm nữa')),
      );
    }
    setState(() {});
  }

  void _removeFromCart(Book book) {
    final existingItem = cart.firstWhere(
      (item) => item.book.id == book.id,
      orElse: () => CartItem(book: book, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      setState(() {
        cart.removeWhere((item) => item.book.id == book.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.name} đã được xóa khỏi giỏ hàng')),
      );
    }
  }

  Future<void> _borrowBooks() async {
    List<String> borrowData =
        cart.where((item) => item.quantity > 0).map((item) {
      return item.book.id; // Lấy ID sách
    }).toList();

    if (borrowData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có sách nào trong giỏ hàng')),
      );
      return;
    }

    String ngaymuon = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse('http://192.168.1.17:3000/phieumuondangchoduyet'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'madocgia': currentReader?.id,
        'ngaymuon': ngaymuon,
        'masachList': borrowData // Danh sách mã sách dưới dạng chuỗi
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi phiếu mượn thành công!')),
      );
      cart.clear(); // Xóa giỏ hàng sau khi gửi thành công
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi phiếu mượn thất bại: ${response.body}')),
      );

      // Phân tích phản hồi để lấy danh sách sách không khả dụng
      final errorData = jsonDecode(response.body);
      List<String> unavailableBooks =
          List<String>.from(errorData['unavailableBooks']);

      // Cập nhật giỏ hàng bằng cách xóa các sách không khả dụng
      setState(() {
        cart.removeWhere((item) => unavailableBooks.contains(item.book.id));
      });
    }
    // Gọi lại fetchBooks() và cập nhật booksFuture
    setState(() {
      loading = true; // Đặt trạng thái đang tải
    });

    // Gọi lại fetchBooks() và cập nhật booksFuture
    booksFuture = fetchBooks();
    await booksFuture; // Đợi cho đến khi danh sách sách được tải lại

    setState(() {
      loading = false; // Đặt trạng thái không còn đang tải
    });
  }

  Future<void> _refreshBooks() async {
    setState(() {
      loading = true; // Đặt trạng thái đang tải
    });

    // Gọi lại fetchBooks
    try {
      booksFuture = fetchBooks(); // Cập nhật booksFuture
      await booksFuture; // Đợi cho đến khi danh sách sách được tải lại
    } catch (error) {
      print('Lỗi khi tải lại sách: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải lại sách: $error')),
      );
    }

    setState(() {
      loading = false; // Đặt trạng thái không còn đang tải
    });
  }
  void _logout() {
    ShareService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(currentReader?.name ?? 'Người dùng không xác định'),
              accountEmail: Text(currentReader?.email ?? 'Không có email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  currentReader?.name?.substring(0, 1) ?? 'U',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              title: Text('Sửa thông tin'),
              onTap: () async {
                if (currentReader != null) {
                  // Kiểm tra xem currentReader có phải là null không
                  // Xử lý sửa thông tin
                  Reader? updatedReader = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(reader: currentReader!),
                    ),
                  );

                  if (updatedReader != null) {
                    setState(() {
                      currentReader = updatedReader; // Cập nhật currentReader với thông tin mới
                    });
                  } else {
                    print('Không có thông tin cập nhật.');
                  }
                } else {
                  print('Độc giả hiện tại là null.');
                }
              },
            ),
            ListTile(
              title: Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(email: currentReader!.email),
                  ),
                );
              },
            ),

            ListTile(
              title: Text('Lịch Sử Mượn'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BorrowRecordsScreen(readerId: currentReader!.id), // Thay 'madocgia_cua_ban' bằng ID thực tế
                  ),
                );
              },
            ),
      ],
        ),
      ),
      appBar: AppBar(
        title: Text('Danh Sách Sách'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Nút refresh
            onPressed: () {
              print('Nút refresh được nhấn'); // Kiểm tra xem nút có hoạt động không
              _refreshBooks(); // Gọi phương thức tải lại
            },
          ),

          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text('Giỏ Hàng'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            CartItem item = cart[index];
                            return ListTile(
                              title: Text(item.book.name),
                              subtitle: Text('Số lượng: ${item.quantity}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _removeFromCart(item.book);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _borrowBooks(); // Gửi phiếu mượn
                            Navigator.of(context).pop();
                          },
                          child: Text('Gửi Phiếu Mượn'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Đóng'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: booksFuture,
        builder: (context, snapshot) {
          if (loading) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có sách nào'));
          }

          // Lọc sách có sẵn để cho mượn
          _availableBooks =
              snapshot.data!.where((book) => book.trangthai == 0).toList();

          if (_availableBooks.isEmpty) {
            return Center(child: Text('Không có sách nào có sẵn để mượn'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            padding: const EdgeInsets.all(10),
            itemCount: _availableBooks.length,
            itemBuilder: (context, index) {
              Book book = _availableBooks[index];
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: book.imageBase64 != null &&
                                book.imageBase64!.isNotEmpty
                            ? Image.memory(
                                base64Decode(book.imageBase64!),
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.book, size: 50),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        book.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ButtonBar(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add), // Dấu +
                          onPressed: () =>
                              _addToCart(book), // Thêm sách vào giỏ hàng
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
