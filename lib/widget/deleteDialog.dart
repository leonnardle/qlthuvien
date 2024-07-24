import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showDeleteConfirmationDialog(BuildContext context, Function(bool) onConfirmed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Xác nhận xóa "),
        content: Text("Bạn có chắc chắn muốn xóa cuốn sách này không?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Đóng dialog và trả về giá trị false (không xác nhận)
            },
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Đóng dialog và trả về giá trị true (xác nhận)
            },
            child: Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  ).then((confirmed) {
    onConfirmed(confirmed ?? false);
  });
}