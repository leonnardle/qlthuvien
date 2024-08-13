import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luanvan/view/publisher/publisherAdd_pageview.dart';

import '../../model/publisher_model.dart';
import '../../service/publisher_service.dart';
import '../../widget/addButton.dart';
import '../../widget/deleteDialog.dart';
import '../../widget/navbar.dart';
import 'booklistByPublisher_pageview.dart';


class ListPublisher extends StatefulWidget {

  ListPublisher({super.key});

  _ListPublisherState createState() => _ListPublisherState();
}

class _ListPublisherState extends State<ListPublisher> {
  final TextEditingController _searchController = TextEditingController();
  List<Publisher> _allPublisher = [];
  List<Publisher> _filteredPublisher = [];
  Future<void> _fetchPublisher() async {
    try {
      final bookTypes = await fetchPublisher();
      setState(() {
        _allPublisher = bookTypes;
        _filteredPublisher = _searchController.text.isEmpty
            ? bookTypes
            : bookTypes.where((bookType) {
          final nameLower = bookType.id.toLowerCase();
          return nameLower.contains(_searchController.text.toLowerCase());
        }).toList();
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  void _filterPublisher() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPublisher = _allPublisher.where((bookType) {
        final nameLower = bookType.id.toLowerCase();
        return nameLower.contains(query);
      }).toList();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPublisher();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Danh Sách nhà xuất bản'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300), // Optional: Constrain width
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo tên loại...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _filterPublisher(); // Gọi phương thức lọc khi nhấn nút tìm kiếm
            },
          ),
        ],
      ),
      body:FutureBuilder<List<Publisher>>(
      future: fetchPublisher(),
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return const CircularProgressIndicator();
        }else if(snapshot.hasError){
          return const Center(child: Text('co loi xay ra'),);
        }else if(!snapshot.hasData||snapshot.data!.isEmpty){
          return const Center(child: Text('khong co sach'),);
        }else{
          final bookTypesList = _filteredPublisher.isNotEmpty
              ? _filteredPublisher
              : _allPublisher; // Sử dụng _allBookTypes
          return Stack(
        children: [
          Positioned.fill(
            top: 10,
            child:
              ListView.builder(
              itemCount: bookTypesList.length,
              itemBuilder: (context, index) {
                Publisher publisher=bookTypesList[index];
                   return GestureDetector(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nhà xuất bản ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('mã nxb : ${publisher.id}'),
                                SizedBox(height: 4),
                                Text('tên nxb : ${publisher.name}'),
                                SizedBox(height: 4),
                                Text('địa chỉ : ${publisher.address}'),
                                SizedBox(height: 4),
                                Text('sdt : ${publisher.phonenumber}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showEditDialog(context, publisher);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(context, (confirm) async {
                                if(confirm){
                                  bool response = await deletePublisher(publisher);
                                  if (response) {
                                    _fetchPublisher();
                                    _filterPublisher();
                                  }else{
                                    if(mounted){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(''
                                          'đã có sách cho nhà xuất bản này . hãy kiểm tra lại')));
                                    }
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                   /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublisherBooksPage(publisher: publisher),
                      ),
                    );*/

                  },
                );
              },
            ),
          ),
        ],
      );
    }}),
      floatingActionButton: AddButton(
        onPressed: () async {
          bool result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPublisher()),
          );
          if (result) {
            await _fetchPublisher(); // Cập nhật danh sách sau khi thêm mới
            _filterPublisher(); // Cập nhật kết quả tìm kiếm
          }
        },
      ),

    );
  }

  void _showEditDialog(BuildContext context, Publisher publisher) async {
    late TextEditingController tennxbController = TextEditingController(text: publisher.name);
    late TextEditingController diachiController = TextEditingController(text: publisher.address);
    late TextEditingController sdtController = TextEditingController(text: publisher.phonenumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh Sửa nxb'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tennxbController,
                decoration: InputDecoration(
                  labelText: 'Tên nxb',
                ),
              ),
              TextField(
                controller: diachiController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                ),
              ),
              TextField(
                controller: sdtController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11), // Giới hạn 11 ký tự
                ],
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
                final newName = tennxbController.text;
                final newAddress = diachiController.text;
                final newPhoneNumber = sdtController.text;

                // Cập nhật thông tin nhà xuất bản
                publisher.name = newName;
                publisher.address = newAddress;
                publisher.phonenumber = newPhoneNumber;
                try {
                  if(mounted) {
                    await updatePublisher(publisher);
                    Navigator.of(context).pop();
                    _fetchPublisher();
                  }
                }catch(error){
                  rethrow;
                }
              },
              child: Text('Cập Nhật'),
            ),
          ],
        );
      },
    );
  }
}


