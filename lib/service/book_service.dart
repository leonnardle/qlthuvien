import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/service/publisher_service.dart';
import '../config.dart';
import '../model/book_model.dart';

List<Book> parseBook(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<Book>((json) => Book.fromJson(json)).toList();
}
Stream<List<Book>> fetchBooks() async* {
  try {
    final response = await http.get(Uri.parse('${ConFig.apiUrl}/sach/'));
    if (response.statusCode == 200) {
      List<Book> books = parseBook(response.body);

      for (int i = 0; i < books.length; i++) {
        try {
          final publishersResponse = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${books[i].id}/danhsachnxb'));
          if (publishersResponse.statusCode == 200) {
            final publishersData = jsonDecode(publishersResponse.body)['data'];

            if (publishersData != null && publishersData is List) {
              books[i].publishersList = publishersData.map((p) => Publisher.fromJson(p)).toList();
            } else {
              print('chưa có nhà xuất bản cho id: ${books[i].id}');
              books[i].publishersList = [];
            }
          } else {
            print('Failed to load publishers for book ${books[i].id}');
            books[i].publishersList = [];
          }
        } catch (e) {
          print('Error fetching publishers for book ${books[i].id}: $e');
          books[i].publishersList = [];
        }

        yield books.sublist(0, i + 1); // Trả về từng phần của danh sách sách
        await Future.delayed(Duration(milliseconds: 100)); // Giả lập độ trễ tải dữ liệu
      }
    } else {
      throw Exception('Unable to connect to API');
    }
  } catch (e) {
    print('Error fetching books: $e');
    yield* Stream.error(e); // Ném lỗi ra Stream
  }
}

Future<void> insertBook(Book book) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.17:3000/sach'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'masach': book.id,
      'tensach': book.name,
      'matg': book.authorId,
      'manxbList': book.listPublisherIds,  // Gửi danh sách ID của nhà xuất bản
      'maloai': book.bookTypeId,
      'mota': book.description,
      'hinhanh': book.imageBase64,
      'soluong': book.quantity
    }),
  );

  if (response.statusCode == 200) {
    print('Đã thêm sách thành công');
  } else {
    print('Lỗi khi thêm sách: ${response.statusCode}');
  }
}



Future<void> updateBook(Book book, List<String> manxbList) async {
  final response = await http.put(
    Uri.parse('http://192.168.1.17:3000/sach/${book.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'masach': book.id,
      'tensach': book.name,
      'matg': book.authorId,
      'manxbList': manxbList,  // Gửi danh sách ID của nhà xuất bản
      'maloai': book.bookTypeId,
      'mota': book.description,
      'hinhanh': book.imageBase64,
      'soluong': book.quantity
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể cập nhật thông tin sách');
  }
}

Future<void> deleteBook(String id) async {
  final response = await http.delete(
    Uri.parse('http://192.168.1.17:3000/sach/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể xóa sách');
  }
}
Future<List<Publisher>> fetchPublisherByBookId(String BookId) async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${BookId}/danhsachnxb'));
  if (response.statusCode == 200) {
    return parsePublisher(response.body);
  } else {
    throw Text('không tìm thấy nha xuat ban nào từ mã sach này');
  }
}