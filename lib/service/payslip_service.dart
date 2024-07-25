import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/payslip_model.dart';

import '../model/book_model.dart';



List<PaySlip> parsePaySlip(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<PaySlip>((json) => PaySlip.fromJson(json)).toList();
}

Future<List<PaySlip>> fetchPaySlip() async {
  try {
    final response = await http.get(Uri.parse('${ConFig.apiUrl}/phieutra/'));
    List<PaySlip>list = parsePaySlip(response.body);
    if (response.statusCode == 200) {
      // tien hanh nap sach cho tung phieu muon
      final future = list.map((loanslip) async {
        try{
          final bookresponse = await http.get(
              Uri.parse('${ConFig.apiUrl}/phieutra/${loanslip.id}/danhsachsachtra'));
          if (bookresponse.statusCode == 200) {
            final bookTypeData = jsonDecode(bookresponse.body)['data'];
            if (bookTypeData != null && bookTypeData is List) {
              loanslip.bookList = bookTypeData.map((p) => Book.fromJson(p)).toList();
            } else {
              print('Chưa có sach cho id: ${loanslip.id}');
            }
          }}catch(error){
          // neu loi thi cho list do la rong
          print('loi khi nap thong tin cho phieu muon ${loanslip.id}');
          loanslip.bookList = [];
        }
      }).toList();
      await Future.wait(future);
      return list;
    } else {
      throw Exception('unable connect to api');
    }
  }catch(error){
    rethrow;
  }
}
Future<bool> insertPaySlip(PaySlip paySlip) async {
  try {
    final response = await http.post(Uri.parse('${ConFig.apiUrl}/phieutra/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'mapt': paySlip.id,
        'maphieumuon': paySlip.loanId,
        'ngaytra': paySlip.payDay.toIso8601String().split('T')[0], //format ngay
        'ghichu': paySlip.note,
        "masachList":paySlip.listBookIds
      }),
    );
    /* print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/docgia/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': reader.id, 'tenloai': reader.loanId})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      print('Đã thêm phieu tra thành công');
      return true;
    } else {
      print('Đã xảy ra lỗi khi thêm phieutra. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}');
      return false;

    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu thêm phieutra: $e');
  }
  return false;

}
Future<bool> updatePaySlip(PaySlip paySlip) async {
  try {
    final response = await http.put(Uri.parse('${ConFig.apiUrl}/phieutra/${paySlip.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'maphieumuon': paySlip.loanId,
        'ngaytra': paySlip.payDay.toIso8601String().split('T')[0], //format ngay
        'ghichu': paySlip.note,
        "masachList":paySlip.listBookIds
      }),
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id, 'tenloai': book.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*//*
*/

    if (response.statusCode == 200) {
      print('Đã xảy ra lỗi khi cập nhật loại sách cho ${paySlip.id}');
      return true;
    } else {
      print('Đã xảy ra lỗi khi cập nhật loại sách cho ${paySlip.id}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu cập nhật loại sách: $e');
    return false;
  }
}
Future<bool> deletePaySlip(PaySlip paySlip) async {
  try {
    final response =  await http.delete(
        Uri.parse('${ConFig.apiUrl}/phieutra/${paySlip.id}'),
        headers: {"Accept": "application/json"}
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      return true;
    }else{
      return false;
    }
  } catch (e) {

    return false;
  }
}


