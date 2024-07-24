import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luanvan/config.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/model/loanslip_model.dart';
import 'package:luanvan/service/book_service.dart';

List<LoanSlip> parseLoanslip(String responseBody) {
  final parsed = json.decode(responseBody)['data'] as List<dynamic>;
  return parsed.map<LoanSlip>((json) => LoanSlip.fromJson(json)).toList();
}

Future<List<LoanSlip>> fetchLoanslip() async {
  try {
    final response = await http.get(Uri.parse('${ConFig.apiUrl}/phieumuon/'));
    List<LoanSlip>list = parseLoanslip(response.body);
    if (response.statusCode == 200) {
      // tien hanh nap sach cho tung phieu muon
      final future = list.map((loanslip) async {
        try{
        final bookresponse = await http.get(
            Uri.parse('${ConFig.apiUrl}/phieumuon/${loanslip.id}/danhsachsach'));
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
Future<void> insertLoanslip(LoanSlip loanSlip) async {
  try {
    final response = await http.post(Uri.parse('${ConFig.apiUrl}/phieumuon/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'mapm': loanSlip.id,
        'madocgia': loanSlip.readerId,
        'ngaymuon': loanSlip.loanDay.toIso8601String().split('T')[0], //format ngay
        'trangthai': loanSlip.status,
        "masachList":loanSlip.listBookIds
      }),
    );
    /* print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/docgia/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': reader.id, 'tenloai': reader.loanId})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      print('Đã thêm doc gia thành công');
    } else {
      print('Đã xảy ra lỗi khi thêm docgia. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}');
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu thêm docgia: $e');
  }
}
Future<bool> updateLoanslip(LoanSlip loanSlip) async {
  try {
    final response = await http.put(Uri.parse('${ConFig.apiUrl}/phieumuon/${loanSlip.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'maphieumuon': loanSlip.id,
        'madocgia': loanSlip.readerId,
        'masachList': loanSlip.listBookIds
      }),
    );

/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id, 'tenloai': book.name})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/
    if (response.statusCode == 200) {
      print('cap nhat thanh cong cho:  ${loanSlip.id}');
      return true;
    } else {
      print('Đã xảy ra lỗi khi cập nhật cho phieu muon:  ${loanSlip.id}');
      return false;
    }
  } catch (e) {
    print('Đã xảy ra lỗi khi gửi yêu cầu cập cho phieu muon: $e');
  }
  return false;

}
Future<bool> deleteLoanslip(LoanSlip book) async {
  try {
    final response =  await http.delete(
        Uri.parse('${ConFig.apiUrl}/phieumuon/${book.id}'),
        headers: {"Accept": "application/json"}
    );
/*    print('Yêu cầu gửi đi: ${Uri.parse('${ConFig.apiUrl}/Reader/')}');
    print('Dữ liệu gửi đi: ${jsonEncode({'maloai': book.id})}');
    print('Trạng thái phản hồi: ${response.statusCode}');
    print('Nội dung phản hồi: ${response.body}');*/

    if (response.statusCode == 200) {
      return true;
    }else{

    }
  } catch (e) {

    return false;
  }
  return false;
}

Future<bool> checkLoanSlipExists(String loanIds) async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/phieumuon/$loanIds'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'];
  } else {
    return false;
  }
}
