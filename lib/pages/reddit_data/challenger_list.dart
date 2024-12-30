import 'package:flutter/material.dart';
import 'package:metenoxin_flutter/services/api_call.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> fetchAndStoreData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching data...';
    });

    // Call the function from the ApiService
    final result = await _apiService.fetchAndStoreData();

    setState(() {
      _statusMessage = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchAndStoreData,
                    child: const Text('Fetch and Store Data'),
                  ),
                ],
              ),
      ),
    );
  }
}
