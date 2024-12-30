import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChampionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchAndStoreChampionData() async {
    const url =
        'https://ddragon.leagueoflegends.com/cdn/14.24.1/data/en_US/champion.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Create a single document to store all champions
        await _firestore.collection('champion_data').doc('all_champions').set({
          'data': data['data'], // Store all champion data in a single field
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return 'Champion data successfully stored as a single document!';
      } else {
        return 'Failed to fetch champion data: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
