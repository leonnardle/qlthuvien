import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';

import '../model/booktype_model.dart';

List<BookType> parseBookType(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<BookType>((json) => BookType.fromJson(json)).toList();
}

Future<List<BookType>> fetchBookType() async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/booktype/'));
  if (response.statusCode == 200) {
    return parseBookType(response.body);
  } else {
    throw Exception('unable connect to api');
  }
}
Future<void> insertBooktype(BookType booktype) async {
  try {
    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/booktype/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'maloai': booktype.id,
        'tenloai': booktype.name,
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/booktype/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': booktype.id, 'tenloai': booktype.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      print('Đã thêm loại sách thành công');
    } else {
      print('Đã xảy ra lỗi khi thêm loại sách. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}');
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu thêm loại sách: $e');
  }
}
Future<void> updateBooktype(BookType book) async {
  try {
    final response =  await http.put(
        Uri.parse('${ConFig.apiUrl}/booktype/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
        'maloai': book.id,
        'tenloai': book.name
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/booktype/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id, 'tenloai': book.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      fetchBookType();
    } else {
      print('Đã xảy ra lỗi khi cập nhật loại sách cho ${book.id}');
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu cập nhật loại sách: $e');
  }
}
Future<bool> deleteBooktype(BookType book) async {
  try {
    final response =  await http.delete(
        Uri.parse('${ConFig.apiUrl}/booktype/${book.id}'),
        headers: {"Accept": "application/json"}
    );

/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/booktype/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      print('Đã xóa loại sách thành công');
      return true;

    } else {
      print('Đã xảy ra lỗi khi xóa loại sách cho ${book.id}');
      return false;

    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu xóa loại sách: $e');
    return false;

  }
}

