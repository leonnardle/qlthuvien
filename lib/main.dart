import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/service/shared.dart';
import 'package:luanvan/view/home_pageview.dart';
import 'package:luanvan/view/login_pageview.dart';
import 'package:luanvan/view/register_pageview.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Widget _defaultHome = const LoginPage();

  if (defaultTargetPlatform == TargetPlatform.android) {
    bool _result = await ShareService.isLogged();
    if (_result) {
      _defaultHome =const MyHomePage();
    }
  }

  runApp(MyApp(defaultHome: _defaultHome));
}

class MyApp extends StatelessWidget {
  final Widget? defaultHome;

  const MyApp({super.key,  this.defaultHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: defaultHome,
    );
  }
}
