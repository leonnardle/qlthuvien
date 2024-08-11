import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../service/aceptService.dart';

class PendingRequestsPage extends StatefulWidget {
   final Function() onUpdateLoanSlipCount;
   const PendingRequestsPage({Key? key, required this.onUpdateLoanSlipCount}) : super(key: key);
   @override
  _PendingRequestsPageState createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  late Future<List<dynamic>> _pendingRequests;

  @override
  void initState() {
    super.initState();
    _pendingRequests = fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách phiếu mượn chờ duyệt'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pendingRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final pendingRequests = snapshot.data!;

            return ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                return Card(
                  child: ListTile(
                    title: Text('Mã phiếu mượn: ${request['mapm']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã độc giả: ${request['madocgia']}'),
                        Text('Ngày mượn: ${request['ngaymuon']}'),
                        Text('Danh sách sách: ${request['masachList']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            _approveRequest(request['mapm']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteRequest(request['mapm']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _approveRequest(String mapm) async {
    final response = await http.post(
      Uri.parse('${ConFig.apiUrl}/phieumuondangchoduyet/duyet/$mapm'),
    );

    if (response.statusCode == 200) {
      widget.onUpdateLoanSlipCount();
      // Cập nhật danh sách
      setState(() {

        _pendingRequests = fetchPendingRequests(); // Làm mới danh sách phiếu mượn
      });
    } else {
      // Hiển thị thông báo lỗi
    }
  }

  void _deleteRequest(String mapm) async {
    final response = await http.delete(
      Uri.parse('${ConFig.apiUrl}/phieumuondangchoduyet/$mapm'),
    );

    if (response.statusCode == 200) {
      widget.onUpdateLoanSlipCount();
      // Cập nhật danh sách
      setState(() {
        _pendingRequests = fetchPendingRequests(); // Làm mới danh sách phiếu mượn
      });
    } else {
      // Hiển thị thông báo lỗi
    }
  }
}
