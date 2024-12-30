import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Use flutter_dotenv
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final apiKey = dotenv.env['RIOT_GAMES_API'];

  Future<String> fetchAndStoreData() async {
    // Construct the API URL
    String apiUrl =
        'https://na1.api.riotgames.com/lol/league/v4/challengerleagues/by-queue/RANKED_SOLO_5x5?api_key=$apiKey';

    try {
      // Fetch data from the API
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode JSON response
        final data = json.decode(response.body);

        // Store data in Firestore
        await _firestore.collection('riot_challenger_league').add({
          'queueType': data['queue'],
          'tier': data['tier'],
          'entries': data['entries'], // List of players and ranks
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return 'Data successfully stored in Firestore!';
      } else {
        return 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<dynamic>? basicApiCall({
    required String address,
    required String region,
  }) async {
    final url =
        Uri.parse('https://$region.api.riotgames.com/$address?api_key=$apiKey');
    print(url);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        print(url);
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
