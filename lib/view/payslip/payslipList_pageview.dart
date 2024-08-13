
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/book_model.dart';
import 'package:luanvan/service/loanSlip_service.dart';
import 'package:luanvan/service/payslip_service.dart';
import 'package:luanvan/view/payslip/payAdd_pageview.dart';

import '../../function/convertTimeToGMT7.dart';
import '../../model/payslip_model.dart';
import '../../service/book_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';

class ListPaySlip extends StatefulWidget {
  late Future<List<PaySlip>>? PaySlipFuture;

  ListPaySlip({super.key, this.PaySlipFuture});

  @override
  _ListPaySlipState createState() => _ListPaySlipState();
}

class _ListPaySlipState extends State<ListPaySlip> {
  final TextEditingController _searchController = TextEditingController();
  List<PaySlip> _allBookTypes = [];
  List<PaySlip> _filteredPaySlip = [];
  Future<void> _fetchPaySlip() async {
    try {
      final bookTypes = await fetchPaySlip();
      setState(() {
        _allBookTypes = bookTypes;
      });
    } catch (e) {
      // Xu ly su kien neu loi
    }
  }

  void _filterPaySlip() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPaySlip = _allBookTypes.where((bookType) {
        final nameLower = bookType.id.toLowerCase();
        return nameLower.contains(query);
      }).toList();
    });
  }
   @override
  void initState() {
    super.initState();
    //_booktypeFuture = fetchBookType();
    _fetchPaySlip();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách phieu tra'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300), // Optional: Constrain width
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo mã...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _filterPaySlip(); // Gọi phương thức lọc khi nhấn nút tìm kiếm
            },
          ),
        ],

      ),
      body: FutureBuilder<List<PaySlip>>(
          future: widget.PaySlipFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi khi tải phieu tra: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có phieu tra nao'));
            } else {
              final PaySlipsList = _filteredPaySlip.isNotEmpty
                  ? _filteredPaySlip
                  : snapshot.data!;
              return ListView.builder(
                itemCount: PaySlipsList.length,
                itemBuilder: (context, index) {
                  PaySlip paySlip = PaySlipsList[index];
                  return GestureDetector(
                    child: Card(
                      margin:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'phieu tra ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('mã phiếu tra : ${paySlip.id}'),
                                  SizedBox(height: 4),
                                  Text('ma phieu muon : ${paySlip.loanId}'),
                                  SizedBox(height: 4),
                                  Text('Ngày trả: ${formatDateTimeToLocal(paySlip.payDay)}'),
                                  SizedBox(height: 4),
                                  Text('ghi chu : ${paySlip.note}'),
                                  SizedBox(height: 4),
                                  Text('trang thai : ${paySlip.status==true?"da tra":"chua tra"}'),
                                  SizedBox(height: 4),
                                  Text('danh sách sách : ${paySlip.bookList.map((e) => e.name).join(', ')}'),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showEditDialog(context, paySlip);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(context, (confirm) async {
                                  if (confirm) {
                                    bool result=await deletePaySlip(paySlip);
                                    if(result){
                                      _refreshData();
                                    }else{
                                      if(mounted){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('có lỗi xảy ra , đã có phiếu trả tồn tại cho phiếu mượn này '
                                            'bạn không thể xóa nó')));
                                      }}
                                  }
                                });
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {},
                  );
                },
              );
            }
          }),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPaySlip()),
          );
          if (result) {
            _refreshData();
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, PaySlip paySlip) async {
    late TextEditingController maphieumuonController = TextEditingController(text: paySlip.loanId);
    late TextEditingController _bookIdsController = TextEditingController(text: paySlip.bookList.map((e) => e.id).join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa doc gia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maphieumuonController,
                decoration: InputDecoration(
                  labelText: 'mã phieu muon',
                ),
              ),
              TextField(
                controller: _bookIdsController,
                decoration: const InputDecoration(
                  labelText: 'Nhập mã sách',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                List<String> validBookIds = [];
                List<String> invalidBooks = [];
                bool checkloan = await checkLoanSlipExists(maphieumuonController.text);

                if (checkloan) {
                  // Lấy danh sách các sách từ phiếu mượn hiện tại
                  List<Book> loanBook = await fetchBooksByLoanSlip(maphieumuonController.text);
                  List<String> loanBookIds = loanBook.map((e) => e.id).toList();

                  // Lấy danh sách ID sách từ text field
                  List<String> bookIds = _bookIdsController.text.split(',').map((line) => line.trim()).toList();
                  bookIds.removeWhere((id) => id.isEmpty);

                  try {
                    // Kiểm tra sự tồn tại của các sách
                    List<Future<bool>> checkExistenceFutures = bookIds.map((id) => checkBookExists(id)).toList();
                    List<bool> existResults = await Future.wait(checkExistenceFutures);

                    bookIds.asMap().forEach((index, id) {
                      // Kiểm tra nếu sách tồn tại và thuộc về phiếu mượn
                      if (existResults[index] && loanBookIds.contains(id)) {
                        validBookIds.add(id);
                      } else {
                        invalidBooks.add(id);
                      }
                    });

                    if (invalidBooks.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Những sách sau không tồn tại hoặc không thuộc phiếu mượn này: ${invalidBooks.join(', ')}'),
                      ));
                    } else {
                      paySlip.loanId = maphieumuonController.text;
                      paySlip.listBookIds = validBookIds;
                      paySlip.payDay=DateTime.now();
                      bool result = await updatePaySlip(paySlip);

                      if (result && mounted) {
                        _refreshData();
                        Navigator.pop(context, true);
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Không thể chỉnh sửa, đã có phiếu trả tương ứng cho phiếu mượn này'),
                          ));

                      }
                    }
                  } catch (error) {
                    if (kDebugMode) {
                      print("Đã xảy ra lỗi khi sửa phiếu mượn: $error");
                    }
                  }
                  _refreshData(); // Cập nhật dữ liệu sau khi chỉnh sửa
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Không tồn tại phiếu mượn này'),
                  ));
                }
              },
              child: Text('Cập Nhật'),
            ),


          ],
        );
      },
    );
  }
  void _refreshData() {
    setState(() {
      widget.PaySlipFuture = fetchPaySlip(); // Cập nhật Future để lấy dữ liệu mới
    });
  }

}
