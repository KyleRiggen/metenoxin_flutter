import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/services/api_call.dart';
import 'package:metenoxin_flutter/constants.dart';

class FetchChallengers {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();
  final Constants constants = Constants();

  // Fetch summoner IDs and store them in Firestore
  Future<String> fetchAndStoreData({
    required Function(String) onStatusUpdate, // Callback for status updates
  }) async {
    List<String> summonerIds = [];
    String statusMessage = 'Fetching summoner IDs...';

    try {
      for (String region in constants.regions) {
        // Update the status message and notify the UI
        statusMessage = 'Getting challenger list from $region';
        onStatusUpdate(statusMessage);

        // Fetch data from the Riot API
        final data = await _apiService.basicApiCall(
          address: "lol/league/v4/challengerleagues/by-queue/RANKED_SOLO_5x5",
          region: region,
        );

        if (data != null) {
          for (var entry in data['entries']) {
            summonerIds.add(entry['summonerId']);
          }
        }

        // Add a short delay before moving to the next region
        await Future.delayed(Duration(seconds: 1));
      }

      if (summonerIds.isNotEmpty) {
        // Store the summoner IDs in Firestore
        await _firestore
            .collection('summoner_data')
            .doc('challenger_summoners')
            .set({
          'summonerIds': summonerIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        statusMessage = 'Summoner IDs successfully stored in Firestore!';
      } else {
        statusMessage = 'Failed to fetch summoner data';
      }
    } catch (e) {
      statusMessage = 'Error: $e';
    }

    // Return the final status message
    return statusMessage;
  }
}
