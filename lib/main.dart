import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metenoxin_flutter/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Data',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FirebaseInitializer(),
    );
  }
}

class FirebaseInitializer extends StatelessWidget {
  const FirebaseInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error initializing Firebase: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const HomePage();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<FirebaseApp> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      return await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB1LqbRkULObSr6-RhUFZcpwbgVq6I9fPg',
          appId: '1:376124232338:web:dda0692b985b8c80c14c4b',
          messagingSenderId: '376124232338',
          projectId: 'metenoxin',
        ),
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      throw Exception('Failed to initialize Firebase: $e');
    }
  }
}
