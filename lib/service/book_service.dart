import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:luanvan/model/booktype_model.dart';
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

      // Fetch publishers and book types for each book concurrently
      final futures = books.map((book) async {
        try {
          // Fetch publishers
          final publishersResponse = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${book.id}/danhsachnxb'));
          if (publishersResponse.statusCode == 200) {
            final publishersData = jsonDecode(publishersResponse.body)['data'];

            if (publishersData != null && publishersData is List) {
              book.publishersList = publishersData.map((p) => Publisher.fromJson(p)).toList();
            } else {
              print('Chưa có nhà xuất bản cho id: ${book.id}');
              book.publishersList = [];
            }
          } else {
            print('Failed to load publishers for book ${book.id}');
            book.publishersList = [];
          }

          // Fetch book type
          final bookTypeResponse = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${book.id}/danhsachloaisach'));
          if (bookTypeResponse.statusCode == 200) {
            final bookTypeData = jsonDecode(bookTypeResponse.body)['data'];
            if (bookTypeData != null&&bookTypeData is List) {
              book.bookTypeList = bookTypeData.map((p) => BookType.fromJson(p)).toList();
            } else {
              print('Chưa có mã loại cho id: ${book.id}');
            }
          } else {
            print('Failed to load book type for book ${book.id}');
          }
        } catch (e) {
          print('Error fetching publishers or book type for book ${book.id}: $e');
          book.publishersList = [];
        }
      }).toList();

      await Future.wait(futures);

      yield books; // Trả về danh sách đầy đủ sách và nhà xuất bản
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
      'maloaiList': book.listBookTypeIds,
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


Future<void> updateBook(Book book, List<String> manxbList,List<String> manloaiList) async {
  final response = await http.put(
    Uri.parse('http://192.168.1.17:3000/sach/${book.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'masach': book.id,
      'tensach': book.name,
      'matg': book.authorId,
      'manxbList': manxbList,  // Gửi danh sách ID của nhà xuất bản
      'maloaiList': manloaiList,
      'mota': book.description,
      'hinhanh': book.imageBase64,
      'soluong': book.quantity
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể cập nhật thông tin sách');
  }
}

Future<bool> deleteBook(String id) async {
  final response = await http.delete(
    Uri.parse('http://192.168.1.17:3000/sach/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể xóa sách');
  }else{
    return true;
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