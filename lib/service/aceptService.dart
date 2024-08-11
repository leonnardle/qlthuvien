import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:luanvan/config.dart';

Future<List<dynamic>> fetchPendingRequests() async {
  final response = await http.get(Uri.parse('${ConFig.apiUrl}/phieumuondangchoduyet'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to load pending requests');
  }
}
