import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:metenoxin_flutter/pages/reddit_data/challenger_list.dart'; // For decoding JSON

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyB1LqbRkULObSr6-RhUFZcpwbgVq6I9fPg',
    appId: '1:376124232338:web:dda0692b985b8c80c14c4b',
    messagingSenderId: '376124232338',
    projectId: 'metenoxin',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ApiTestPage(),
    );
  }
}
