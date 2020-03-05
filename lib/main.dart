import 'package:flutter/material.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/pages/number_trivia_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.orange.shade800,
        accentColor: Colors.orange.shade600,
      ),
      home: NumberTriviaPage(),
    );
  }
}

