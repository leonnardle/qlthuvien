import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/model/author_model.dart';
import 'package:luanvan/model/publisher_model.dart';
import 'package:luanvan/service/shared.dart';
import 'package:luanvan/view/author/authorList_pageview.dart';
import 'package:luanvan/view/booktype/booktypeList_pageview.dart';
import 'package:luanvan/view/home_pageview.dart';
import 'package:luanvan/view/login_pageview.dart';
import 'package:luanvan/view/publisher/publisherList_pageview.dart';
import 'package:luanvan/view/register_pageview.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'model/booktype_model.dart';


Widget _defaultHome = const LoginPage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    bool _result = await ShareService.isLogged();
    if (_result) {
      _defaultHome = MyHomePage(name: "trung");
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/booktypelist'||settings.name == '/listAuthor') {
          final args = settings.arguments as List<BookType>?;
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ListBookType(items: args ?? []),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);  // Bắt đầu từ bên phải
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end);
              var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));
              var slideTransition = SlideTransition(position: offsetAnimation, child: child);
              return slideTransition;
            },
          );
        }
        return null;  // Trả về null nếu không có route khớp
      },
    routes: {
        '/': (context) => _defaultHome,
        '/home': (context) => MyHomePage(name: "trung"),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisTerPage(),
        '/booktypelist': (context) {
        final list = ModalRoute.of(context)!.settings.arguments as List<BookType>?;
        return ListBookType(items: list ?? []);
      },
      '/authorlist': (context) {
        final list = ModalRoute.of(context)!.settings.arguments as List<Author>?;
        return ListAuthor(items: list ?? []);
      },
      '/publisherlist': (context) {
        final list = ModalRoute.of(context)!.settings.arguments as List<Publisher>?;
        return ListPublisher(items: list ?? list);
      },

      },
    );
  }
}
