import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const TestConnection(),
    );
  }
}

class TestConnection extends StatefulWidget {
  const TestConnection({super.key});

  @override
  State<TestConnection> createState() => _TestConnectionState();
}

class _TestConnectionState extends State<TestConnection> {
  String message = "Testing Firebase connection...";

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Get a reference to Firestore
      final firestore = FirebaseFirestore.instance;

      // Write a test document to a collection named 'test'
      await firestore.collection('test').add({
        'timestamp': DateTime.now(),
        'message': 'Hello, Firebase!',
      });

      // Read back the data to confirm the connection
      final snapshot = await firestore.collection('test').get();
      final docs = snapshot.docs;

      if (docs.isNotEmpty) {
        setState(() {
          message =
              "Firebase is connected! Retrieved data: ${docs.first.data()}";
        });
      } else {
        setState(() {
          message = "Firebase is connected, but no data found.";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error connecting to Firebase: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Connection Test"),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
