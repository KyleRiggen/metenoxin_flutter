import 'package:flutter/material.dart';
import 'package:metenoxin_flutter/services/waterfall/a_fetch_challengers.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final FetchChallengers _fetchChallengers = FetchChallengers();
  bool _isLoading = false;
  String _statusMessage = '';

  // Fetch summoner IDs and store them in Firestore
  Future<void> fetchAndStoreData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching summoner IDs...';
    });

    // Fetch data and provide a callback for real-time status updates
    final result = await _fetchChallengers.fetchAndStoreData(
      onStatusUpdate: (String status) {
        setState(() {
          _statusMessage = status;
        });
      },
    );

    // Update the final status message
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
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              )
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
