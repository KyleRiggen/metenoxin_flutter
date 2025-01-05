import 'package:flutter/material.dart';
import 'package:metenoxin_flutter/utils/champ_setup.dart';
import 'package:metenoxin_flutter/utils/waterfall/a_challengers.dart';
import 'package:metenoxin_flutter/utils/waterfall/g_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  ChampSetup _champSetup = ChampSetup();
  Challengers _challengers = Challengers();
  RedditTextHandler _text = RedditTextHandler();
  // Points _points = Points();

  String _statusMessage = '';
  final List<String> _statusHistory = [];

  void _updateStatusMessage(String newMessage) {
    _statusMessage = newMessage;
    _statusHistory.add(newMessage);

    // Limit history to 10 messages
    if (_statusHistory.length > 200) {
      _statusHistory.removeAt(0);
    }
  }

  Future<void> _setupChampions() async {
    await _champSetup.fetchAndFormatChampionData((status) {
      setState(() {
        _updateStatusMessage(status);
      });
    });
  }

  Future<void> _getChallengers(apiKey) async {
    await _challengers.callChallengers(
      apiKey: apiKey,
      onStatusUpdate: (status) {
        setState(() {
          _updateStatusMessage(status);
        });
      },
    );
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
              onSubmitted: (_) => _getChallengers(_textController.text),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _getChallengers(_textController.text),
                  //onPressed: () => _getChallengers(),
                  child: const Text('Get Challengers'),
                ),
                ElevatedButton(
                  onPressed: _copyRedditText,
                  child: const Text('Copy'),
                ),
                ElevatedButton(
                  onPressed: _setupChampions,
                  child: const Text('Setup Champs'),
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
