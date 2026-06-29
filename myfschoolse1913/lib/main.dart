
import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/login.dart';


// import 'package:http/http.dart' as http;
void main() {
  runApp(const MyFSchoolApp());
}

class MyFSchoolApp extends StatelessWidget {
  const MyFSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFSchool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF3823)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}


