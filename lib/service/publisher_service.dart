import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/publisher_model.dart';

import '../model/book_model.dart';
import 'book_service.dart';

List<Publisher> parsePublisher(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<Publisher>((json) => Publisher.fromJson(json)).toList();
}

Future<List<Publisher>> fetchPublisher() async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/nhaxuatban/'));
  if (response.statusCode == 200) {
    return parsePublisher(response.body);
  } else {
    throw Exception('unable connect to api');
  }
}

Future<bool> insertPublisher(Publisher publisher) async {
  try {
    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/nhaxuatban/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'tennxb': publisher.name,
        'diachi': publisher.address,
        'sdt': publisher.phonenumber
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Publisher/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': Publisher.id, 'tenloai': Publisher.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      print('Đã thêm loại nxb thành công');
      return true;
    } else {
      print(
          'Đã xảy ra lỗi khi thêm nxb. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu thêm nxb: $e');
    return true;
  }
}

Future<void> updatePublisher(Publisher publisher) async {
  try {
    final response = await http.put(
      Uri.parse('${ConFig.apiUrl}/nhaxuatban/${publisher.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'manxb': publisher.id,
        'tennxb': publisher.name,
        'diachi': publisher.address,
        'sdt': publisher.phonenumber
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Publisher/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id, 'tenloai': book.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      fetchPublisher();
    } else {
      print('Đã xảy ra lỗi khi cập nhật loại sách cho ${publisher.id}');
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu cập nhật loại sách: $e');
  }
}

Future<bool> deletePublisher(Publisher publisher) async {
  try {
    final response = await http.delete(
        Uri.parse('${ConFig.apiUrl}/nhaxuatban/${publisher.id}'),
        headers: {"Accept": "application/json"});

/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Publisher/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      print('Đã xóa nxb thành công');
      return true;
    } else {
      print('Đã xảy ra lỗi khi xóa nxb cho ${publisher.id}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu xóa nxb: $e');
    return false;
  }
}

Future<List<Book>> fetchBooksByPublisher(String publisherId) async {
  final response = await http
      .get(Uri.parse('${ConFig.apiUrl}/nhaxuatban/${publisherId}/sach'));
  if (response.statusCode == 200) {
    return parseBook(response.body);
  } else {
    throw Exception(
        'Không tìm thấy sách nào được phát hành từ nhà xuất bản này');
  }
}
