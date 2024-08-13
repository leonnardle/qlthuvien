import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';

import '../model/reader_model.dart';

List<Reader> parseReader(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<Reader>((json) => Reader.fromJson(json)).toList();
}

Future<List<Reader>> fetchReader() async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/docgia/'));
  if (response.statusCode == 200) {
    return parseReader(response.body);
  } else {
    throw Exception('unable connect to api');
  }
}

Future<bool> insertReader(Reader reader) async {
  try {
    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/docgia/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'tendocgia': reader.name,
        //'mapm': reader.loanId!=""?reader.loanId:null,
        'email': reader.email,
        'sdt': reader.phoneNumber
      }),
    );
    /* print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/docgia/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': reader.id, 'tenloai': reader.loanId})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      print('Đã thêm doc gia thành công');
      return true;
    } else {
      print(
          'Đã xảy ra lỗi khi thêm docgia. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu thêm docgia: $e');
    return false;
  }
}

Future<bool> updateReader(Reader reader) async {
  try {
    final response = await http.put(
      Uri.parse('${ConFig.apiUrl}/docgia/${reader.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        //'mapm': "",
        'tendocgia': reader.name,
        'email': reader.email,
        'sdt': reader.phoneNumber
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id, 'tenloai': book.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      //fetchReader();
      return true;
    } else {
      print('Đã xảy ra lỗi khi cập nhật loại sách cho ${reader.id}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu cập nhật loại sách: $e');
    return false;
  }
}

Future<bool> deleteReader(Reader book) async {
  try {
    final response = await http.delete(
        Uri.parse('${ConFig.apiUrl}/docgia/${book.id}'),
        headers: {"Accept": "application/json"});

/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu xóa loại sách: $e');
    return false;
  }
  return false;
}

Future<bool> checkReaderExists(String readerId) async {
  final response =
      await http.get(Uri.parse('${ConFig.apiUrl}/docgia/$readerId'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'];
  } else {
    return false;
  }
}
