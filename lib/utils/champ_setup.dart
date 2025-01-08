import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/waterfall/a_challengers.dart';

class ChampSetup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Constants _constants = Constants();
  Challengers _challengers = Challengers();

  Future<void> fetchAndFormatChampionData(
      Function(String) onStatusUpdate, apiKey) async {
    const String url =
        'https://ddragon.leagueoflegends.com/cdn/14.24.1/data/en_US/champion.json';

    try {
      onStatusUpdate("Fetching champion data...");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        onStatusUpdate("Champion data fetched successfully.");
        // Decode JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Transform the raw data into the desired format
        final Map<String, dynamic> champs = data['data'];
        final List<Map<String, dynamic>> championData = [];

        champs.forEach((champName, champData) {
          championData.add({
            'key': champData['key'],
            'name': champData['name'],
            'picks': 0,
            'bans': 0,
            'kills': 0,
            'deaths': 0,
            'assists': 0,
            'wins': 0,
            'loses': 0,
            'players': [],
            'points': 0,
          });
        });

        await saveListMap(
          data: championData,
          document: _constants.weekLabel,
        );

        onStatusUpdate("Champion data saved to Firestore successfully.");
        _challengers.callChallengers(
            apiKey: apiKey, onStatusUpdate: onStatusUpdate);
      } else {
        throw Exception('Failed to load champion data');
      }
    } catch (e) {
      onStatusUpdate("Error fetching champion data: $e");
      throw Exception('Error fetching champion data: $e');
    }
  }

  Future<void> saveListMap({
    required List<Map<String, dynamic>> data,
    required String document,
  }) async {
    try {
      // Reference to the main document
      final docRef = _firestore.collection("champions").doc(document);

      // Save the list and metadata to the document
      await docRef.set({
        "metadata": "Champ data collection",
        "a_savedAt": FieldValue.serverTimestamp(), // Add server timestamp
        "data": data, // Store the entire list as a field
      });
    } catch (e) {
      throw Exception('Error saving champion data to Firestore: $e');
    }
  }
}
