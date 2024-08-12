import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:luanvan/config.dart';

import '../function/convertTimeToGMT7.dart';

// Hàm để lấy danh sách phiếu mượn
Future<List<Map<String, dynamic>>> fetchBorrowRecords(String readerId) async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/docgia/laydanhsach/$readerId'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return List<Map<String, dynamic>>.from(data['borrowRecords']);
    } else {
      throw Exception(data['message']);
    }
  } else {
    throw Exception('Failed to load borrow records');
  }
}

// Hàm để xây dựng bảng dữ liệu
Widget buildBorrowRecordsTable(List<Map<String, dynamic>> borrowRecords) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columnSpacing: 12.0, // Giảm khoảng cách giữa các cột
      columns: const [
        DataColumn(label: Text('Mã Phiếu Mượn', style: TextStyle(fontSize: 14))),
        DataColumn(label: Text('Ngày Mượn', style: TextStyle(fontSize: 14))),
        DataColumn(label: Text('Ngày trả', style: TextStyle(fontSize: 14))),
        DataColumn(label: Text('Trạng Thái', style: TextStyle(fontSize: 14))),
        DataColumn(label: Text('Mã Sách Thiếu', style: TextStyle(fontSize: 14))),
      ],
      rows: borrowRecords.map((record) {
        return DataRow(cells: [
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(record['mapm'] ?? 'Không có', style: TextStyle(fontSize: 12)), // Kiểm tra null
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              record['ngaymuon'] != null
                  ? formatDateTimeToLocal(DateTime.parse(record['ngaymuon']))
                  : 'Không có', // Kiểm tra null
              style: TextStyle(fontSize: 12),
            ),
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              record['ngaytra'] != null
                  ? formatDateTimeToLocal(DateTime.parse(record['ngaytra']))
                  : 'Không có', // Kiểm tra null
              style: TextStyle(fontSize: 12),
            ),
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(record['status'] ?? 'chưa trả', style: TextStyle(fontSize: 12)), // Kiểm tra null
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              (record['missingBooks'] as List?)?.join(', ') ?? 'Không có', // Kiểm tra null
              style: TextStyle(fontSize: 12),
            ),
          )),
        ]);
      }).toList(),
    ),
  );
}
// Widget hiển thị danh sách phiếu mượn
class BorrowRecordsScreen extends StatefulWidget {
  final String readerId;

  BorrowRecordsScreen({required this.readerId});

  @override
  _BorrowRecordsScreenState createState() => _BorrowRecordsScreenState();
}

class _BorrowRecordsScreenState extends State<BorrowRecordsScreen> {
  late Future<List<Map<String, dynamic>>> futureBorrowRecords;

  @override
  void initState() {
    super.initState();
    futureBorrowRecords = fetchBorrowRecords(widget.readerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch Sử Mượn'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureBorrowRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có phiếu mượn nào.'));
          } else {
            return SingleChildScrollView(
              child: buildBorrowRecordsTable(snapshot.data!),
            );
          }
        },
      ),
    );
  }
}
