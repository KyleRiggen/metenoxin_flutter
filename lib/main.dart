import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Use flutter_dotenv

import 'package:metenoxin_flutter/pages/reddit_data/challenger_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Access Firebase API key from .env
  final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'];
  if (firebaseApiKey == null) {
    throw Exception('FIREBASE_API_KEY is not defined in the .env file');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseApiKey,
      appId: '1:376124232338:web:dda0692b985b8c80c14c4b',
      messagingSenderId: '376124232338',
      projectId: 'metenoxin',
    ),
  );

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
