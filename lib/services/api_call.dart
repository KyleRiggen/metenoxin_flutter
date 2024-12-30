import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchAndStoreData() async {
    const apiUrl =
        'https://na1.api.riotgames.com/lol/league/v4/challengerleagues/by-queue/RANKED_SOLO_5x5?api_key=RGAPI-eba5852f-6d83-4215-a85c-271e502affce';

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
}
