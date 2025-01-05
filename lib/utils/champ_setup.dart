import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';

class ChampSetup {
  FirebaseService _firebaseService = FirebaseService();
  Constants _constants = Constants();

  Future<void> fetchAndFormatChampionData(
      Function(String) onStatusUpdate) async {
    const String url =
        'https://ddragon.leagueoflegends.com/cdn/14.24.1/data/en_US/champion.json';
    try {
      onStatusUpdate("Fetching champion data...");
      final response = await http.get(Uri.parse(url));

      onStatusUpdate("Attempting to delete document");
      await _firebaseService.deleteDocument(document: _constants.new_document);
      onStatusUpdate(
          "Document '${_constants.new_document}' successfully deleted.");

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

        await _firebaseService.saveListMap_setup(
          data: championData,
          document: _constants.new_document,
        );

        onStatusUpdate("Champion data saved to Firestore successfully.");
      } else {
        throw Exception('Failed to load champion data');
      }
    } catch (e) {
      onStatusUpdate("Error fetching champion data: $e");
      throw Exception('Error fetching champion data: $e');
    }
  }
}
