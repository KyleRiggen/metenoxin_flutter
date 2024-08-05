import 'package:flutter/material.dart';
import 'package:metenoxin_flutter/pages/eve_map/eve_map.dart';
import 'package:firebase_core/firebase_core.dart';

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
      title: 'Metenox.in',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EveMap(),
    );
  }
}
