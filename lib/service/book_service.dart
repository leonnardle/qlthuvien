import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/booktype_model.dart';
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/service/publisher_service.dart';
import '../config.dart';
import '../model/book_model.dart';

List<Book> parseBook(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<Book>((json) => Book.fromJson(json)).toList();
}
Future<List<Book>> fetchBooks() async {
  try {
    final apiUrl = getApiUrl();
    final response = await http.get(Uri.parse('$apiUrl/sach/'));
    if (response.statusCode == 200) {
      List<Book> books = parseBook(response.body);

      final futures = books.map((book) async {
        try {
          // nap nha xuat ban
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
          // nap loai sach
          final bookTypeResponse = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${book.id}/danhsachloaisach'));
          if (bookTypeResponse.statusCode == 200) {
            final bookTypeData = jsonDecode(bookTypeResponse.body)['data'];
            if (bookTypeData != null && bookTypeData is List) {
              book.bookTypeList = bookTypeData.map((p) => BookType.fromJson(p)).toList();
            } else {
              print('Chưa có mã loại cho id: ${book.id}');
            }
          } else {
            print('Failed to load book type for book ${book.id}');
          }

          final authorResponse=await http.get(Uri.parse('${ConFig.apiUrl}/sach/${book.id}/danhsachtacgia'));
          if(authorResponse.statusCode==200){
            final authorData=jsonDecode(authorResponse.body)['data'];
            if (authorData != null && authorData is List) {
              book.listauthor =
                  authorData.map((p) => Author.fromJson(p)).toList();
            }
            else{
              if (kDebugMode) {
                print('Failed to load author for author ${book.id}');
              }
            }
          }
        } catch (e) {
          book.bookTypeList = [];
          book.publishersList = [];
          book.listauthor=[];
        }
      }).toList();
      await Future.wait(futures);

      return books; // Trả về danh sách đầy đủ sách và nhà xuất bản
    } else {
      throw Exception('Unable to connect to API');
    }
  } catch (e) {
    print('Error fetching books: $e');
    rethrow; // Ném lỗi ra ngoài
  }
}
Future<bool> insertBook(Book book) async {

  final response = await http.post(
    Uri.parse('${ConFig.apiUrl}/sach'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'tensach': book.name,
      'manxbList': book.listPublisherIds,
      'maloaiList': book.listBookTypeIds,
      'matacgiaList': book.listAuthorIds,
      'mota': book.description,
      'hinhanh': book.imageBase64,
    }),
  );

  if (response.statusCode == 200) {
    print('Đã thêm sách thành công');
    return true;
  } else {
    print('Lỗi khi thêm sách: ${response.statusCode}');
    return false;
  }
}
Future<void> updateBook(Book book, List<String> manxbList,List<String> manloaiList,List<String> matgList) async {
  final response = await http.put(
    Uri.parse('${ConFig.apiUrl}/sach/${book.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'masach': book.id,
      'tensach': book.name,
      'manxbList': manxbList,  // Gửi danh sách ID của nhà xuất bản
      'maloaiList': manloaiList,
      'matacgiaList': matgList,
      'mota': book.description,
      'hinhanh': book.imageBase64,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể cập nhật thông tin sách');
  }
}
Future<bool> deleteBook(String id) async {
  final response = await http.delete(
    Uri.parse('${ConFig.apiUrl}/sach/$id'),
  );

  if (response.statusCode != 200) {
    return false;

  }else{
    return true;
  }
}
Future<List<Publisher>> fetchPublisherByBookId(String BookId) async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/sach/${BookId}/danhsachnxb'));
  if (response.statusCode == 200) {
    return parsePublisher(response.body);
  } else {
    //throw Text('không tìm thấy nha xuat ban nào từ mã sach này');
    throw Exception('Không tìm thấy thấy nha xuat ban nào từ mã sach này');

  }
}
Future<bool> checkBookExists(String bookIds) async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/sach/$bookIds'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'];
  } else {
    return false;
  }
}