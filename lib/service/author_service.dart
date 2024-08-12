import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/author_model.dart';

import '../model/booktype_model.dart';

List<Author> parseAuthor(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<Author>((json) => Author.fromJson(json)).toList();
}

Future<List<Author>> fetchAuthor() async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/tacgia/'));
  if (response.statusCode == 200) {
    return parseAuthor(response.body);
  } else {
    throw Exception('unable connect to api');
  }
}
Future<Map<String, dynamic>?> insertAuthor(Author author) async {

  final response = await http.post(
    Uri.parse('${ConFig.apiUrl}/tacgia/'),  // Thay đổi URL nếu cần
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      "tentacgia": author.name,
      "quoctich": author.country,
      "tieusu": author.story,
      "email": author.email,
      "image": author.imageBase64
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to add author');
  }
}
Future<bool> deleteAuthor(Author author) async {
  try {
    final response =  await http.delete(
        Uri.parse('${ConFig.apiUrl}/tacgia/${author.id}'),
        headers: {"Accept": "application/json"}
    );

    if (response.statusCode == 200) {
      print('Đã xóa tác giả thành công');
      return true;

    } else {
      print('Đã xảy ra lỗi khi  xóa tác giả cho ${author.id}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu xóa loại sách: $e');
    return false;

  }

}
Future<bool> updateAuthor(Author author) async {
  try{
    final response = await http.put(
      Uri.parse('http://192.168.1.17:3000/tacgia/${author.id}'),  // Thay đổi URL nếu cần
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "matacgia": author.id,
        "tentacgia": author.name,
        "quoctich": author.country,
        "tieusu": author.story,
        "email": author.email,
        "image": author.imageBase64
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  catch(error){
    throw Exception('Failed to update author');
  }
}

