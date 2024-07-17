import 'dart:convert';

import 'package:flutter/material.dart';

import '../../model/book_model.dart';
import '../../model/publisher_model.dart';
import '../../service/publisher_service.dart';

class PublisherBooksPage extends StatefulWidget {
  final Publisher publisher;

  PublisherBooksPage({required this.publisher, Key? key}) : super(key: key);

  @override
  _PublisherBooksPageState createState() => _PublisherBooksPageState();
}

class _PublisherBooksPageState extends State<PublisherBooksPage> {
  late Future<List<Book>> _booksFuture;



  @override
  void initState() {
    super.initState();
    _booksFuture=fetchBooksByPublisher(widget.publisher.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sách của ${widget.publisher.name}'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sách nào'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 120,
                          child: book.imageBase64 != null && book.imageBase64!.isNotEmpty
                              ? Image.memory(
                            base64Decode(book.imageBase64!),
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.person, size: 80), // Placeholder nếu không có hình ảnh
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sách ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(height: 4),
                              Text('Tên sách : ${book.name}'),
                     /*         SizedBox(height: 4),
                              Text('mã loại : ${book.bookTypeId}'),*/
                            ],
                          ),
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
}
