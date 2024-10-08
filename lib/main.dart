import 'package:flutter/material.dart';
import 'Login/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState(){
    return _MyAppState();
  }
}
class _MyAppState extends State<MyApp>{
  @override
  void initState (){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      title: "Firebase tutorial",
      home: LoginPage(),
    );
  }
}
