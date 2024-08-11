import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerDemo extends StatefulWidget {
  @override
  _DatePickerDemoState createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('Chọn Ngày'),
          ),
          SizedBox(height: 20),
          Text(
            _selectedDate == null
                ? 'Chưa chọn ngày'
                : 'Ngày đã chọn: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}