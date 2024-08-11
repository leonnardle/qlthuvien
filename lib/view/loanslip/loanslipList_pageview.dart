
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/loanslip_model.dart';
import 'package:luanvan/service/loanSlip_service.dart';
import 'package:luanvan/view/payslip/payslipAdd_pageview.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import '../../function/convertTimeToGMT7.dart';
import '../../service/book_service.dart';
import '../../service/reader_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import 'loanslipAdd_pageview.dart';

class ListLoanSlip extends StatefulWidget {
  late Future<List<LoanSlip>>? LoanSlipFuture;

  ListLoanSlip({super.key, this.LoanSlipFuture});

  @override
  _ListBookTypeState createState() => _ListBookTypeState();
}

class _ListBookTypeState extends State<ListLoanSlip> {
  final TextEditingController _searchController = TextEditingController();
  List<LoanSlip> _allBookTypes = [];
  List<LoanSlip> _filteredLoanSlip = [];
  Future<void> _fetchLoanSlip() async {
    try {
      final bookTypes = await fetchLoanslip();
      setState(() {
        _allBookTypes = bookTypes;
      });
    } catch (e) {
      // Xu ly su kien neu loi
    }
  }

  void _filterLoanSlip() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLoanSlip = _allBookTypes.where((bookType) {
        final nameLower = bookType.id.toLowerCase();
        return nameLower.contains(query);
      }).toList();
    });
  }
   @override
  void initState() {
    super.initState();
    //_booktypeFuture = fetchBookType();

    _fetchLoanSlip();
    _searchController.addListener(() {
      _filterLoanSlip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách phieu muon'),
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
        ],
      ),
      body: FutureBuilder<List<LoanSlip>>(
          future: widget.LoanSlipFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Lỗi khi tải phieu muon: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có phieu muon nao'));
            } else {
              final loanSlipsList = _filteredLoanSlip.isNotEmpty
                  ? _filteredLoanSlip
                  : snapshot.data!;
              return ListView.builder(
                itemCount: loanSlipsList.length,
                itemBuilder: (context, index) {
                  LoanSlip loanSlip = loanSlipsList[index];
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
                                    'phieu muon ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('mã phiếu mượn : ${loanSlip.id}'),
                                  SizedBox(height: 4),
                                  Text('ma doc gia : ${loanSlip.readerId}'),
                                  SizedBox(height: 4),
                                  Text('danh sách sách : ${loanSlip.bookList.map((e) => e.name).join(', ')}'),
                                  SizedBox(height: 4),
                                  Text('Ngày muon: ${formatDateTimeToLocal(loanSlip.loanDay)}'),
                                  SizedBox(height: 4),
                                  Text('trang thai : ${loanSlip.status==true?"da tra":"chua tra"}'),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showEditDialog(context, loanSlip);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(context, (confirm) async {
                                  if (confirm) {
                                    bool result=await deleteLoanslip(loanSlip);
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
                            IconButton(
                              onPressed: () {
                                _showPaySlipDialog(context, loanSlip);
                                _refreshData();
                              },
                              icon: Icon(Icons.library_add_check_sharp),
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
            MaterialPageRoute(builder: (context) => AddLoanSlip()),
          );
          if (result) {
            _refreshData();
          }
        },
      ),
    );
  }
  void _showPaySlipDialog(BuildContext context, LoanSlip loanSlip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tạo Phiếu Trả'),
          content: AddReturnSlipFromLoanpage(loanSlip: loanSlip),
        );
      },
    ).then((result) {
        _refreshData();
    });
  }
  void _showEditDialog(BuildContext context, LoanSlip loanSlip) async {
    late TextEditingController madocgiaController = TextEditingController(text: loanSlip.readerId);
    late TextEditingController _bookIdsController = TextEditingController(text: loanSlip.bookList.map((e) => e.id).join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa doc gia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: madocgiaController,
                decoration: InputDecoration(
                  labelText: 'mã doc gia',
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
                bool checkReader = await checkReaderExists(madocgiaController.text);
                if (checkReader) {
                  List<String> bookIds = _bookIdsController.text.split(',').map((line) => line.trim()).toList();
                  bookIds.removeWhere((id) => id.isEmpty);
                  try {
                    List<Future<bool>> checkExistenceFutures = bookIds.map((id) => checkBookExists(id)).toList();
                    List<bool> existResults = await Future.wait(checkExistenceFutures);

                    bookIds.asMap().forEach((index, id) {
                      if (existResults[index]) {
                        validBookIds.add(id);
                      } else {
                        invalidBooks.add(id);
                      }
                    });

                    if (invalidBooks.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Những sách sau không tồn tại: ${invalidBooks.join(', ')}'),
                      ));
                    } else {
                      loanSlip.readerId = madocgiaController.text;
                      loanSlip.listBookIds = validBookIds;
                      bool result=await updateLoanslip(loanSlip);
                      if(result&&mounted){
                        Navigator.pop(context, true);
                        _refreshData();
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('không thể chỉnh sửa đã có phiếu trả tương ứng cho phiếu mượn này'),
                        ));
                      }

                    }
                  } catch (error) {
                    if (kDebugMode) {
                      print("Đã xảy ra lỗi khi sửa phiếu mượn: $error");
                    }
                  }
                  _refreshData(); // Cập nhật dữ liệu sau khi chỉnh sửa
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
      widget.LoanSlipFuture = fetchLoanslip(); // Cập nhật Future để lấy dữ liệu mới
    });
  }

}
