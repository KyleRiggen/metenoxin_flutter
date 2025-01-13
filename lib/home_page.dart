import 'package:flutter/material.dart';
import 'package:metenoxin_flutter/utils/champ_setup.dart';
import 'package:metenoxin_flutter/utils/waterfall/g_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  ChampSetup _champSetup = ChampSetup();
  RedditTextHandler _text = RedditTextHandler();

  String _statusMessage = '';
  final List<String> _statusHistory = [];

  void _updateStatusMessage(String newMessage) {
    _statusMessage = newMessage;
    _statusHistory.add(newMessage);

    if (_statusHistory.length > 200) {
      _statusHistory.removeAt(0);
    }
  }

  Future<void> _setupChampions(apiKey) async {
    await _champSetup.fetchAndFormatChampionData((status) {
      setState(() {
        _updateStatusMessage(status);
      });
    }, apiKey);
  }

  void _copyRedditText() async {
    await _text.toRedditText(
      onStatusUpdate: (status) {
        setState(() {
          _updateStatusMessage(status);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reddit champ data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter API',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _setupChampions(_textController.text),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _copyRedditText,
                  child: const Text('Copy'),
                ),
                ElevatedButton(
                  onPressed: () => _setupChampions(_textController.text),
                  child: const Text('Champs'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('Error')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _statusHistory.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Text(
                      _statusHistory[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
