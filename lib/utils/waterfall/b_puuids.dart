import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/waterfall/c_matches.dart';

class Puuids {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ApiCalls _apiCalls = ApiCalls();
  Constants constants = Constants();
  Matches _matches = Matches();

  Future<void> callChallengers({
    required String apiKey,
    required Function(String) onStatusUpdate,
  }) async {
    List<Map<String, String>> puuids = [];
    try {
      onStatusUpdate("Starting to fetch puuid data...");
      for (String region in constants.regions) {
        List<Map<String, dynamic>> challengersData =
            await getChallengers(region: region);
        onStatusUpdate("fetched challenger list from $region");

        onStatusUpdate("$region from firebase");
        int callCount = 0;
        for (var player in challengersData) {
          if (callCount >= constants.apiCallNumber) {
            onStatusUpdate(
                "$region Reached the limit of ${constants.apiCallNumber}");
            break;
          }

          try {
            // Make the API call to fetch summoner data
            var result = await _apiCalls.basicApiCall(
              address: "lol/summoner/v4/summoners/${player["summonerId"]}",
              region: region,
              apiKey: apiKey,
            );

            if (result != null && result.containsKey('puuid')) {
              puuids.add({'region': region, 'puuid': result['puuid']});
              callCount++;
              onStatusUpdate(
                  "$region puuids=${puuids.length}  $callCount/${challengersData.length}");
            } else {
              onStatusUpdate(
                  "Missing or invalid 'puuid' for player ${player["summonerId"]} in region $region with a call count of $callCount");
            }
          } catch (apiError) {
            onStatusUpdate(
                "Error fetching data for player ${player["summonerId"]} in region $region: $apiError");
            continue; // Log error and continue with the next player
          }
        }
      }
      onStatusUpdate("saving puuids to db");
      savePuuids(puuids: puuids);
      onStatusUpdate("saved puuids to db");
      _matches.getMatches(onStatusUpdate: onStatusUpdate, apiKey: apiKey);
    } catch (e) {
      onStatusUpdate("Error fetching challenger data: $e");
      throw Exception('Error fetching challenger data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChallengers({
    required String region,
  }) async {
    try {
      // Get the document reference for the specific region
      final docRef = _firestore.collection("players").doc("challengers");
      final docSnapshot = await docRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final challengersData = data[region];

        // If the challengers data exists, return it
        if (challengersData != null) {
          return List<Map<String, dynamic>>.from(challengersData);
        } else {
          throw Exception("Challenger data not found in Firestore.");
        }
      } else {
        throw Exception("Region document does not exist in Firestore.");
      }
    } catch (e) {
      throw Exception('Error reading challenger data from Firestore: $e');
    }
  }

  Future<void> savePuuids({
    required List<Map<String, String>> puuids,
  }) async {
    try {
      // Get the document reference for the region
      final docRef = _firestore.collection("players").doc("puuids");

      // Save the PUUIDs as a field in the document
      await docRef.set({
        "puuids": puuids,
      });
    } catch (e) {
      throw Exception('Error saving PUUIDs to Firestore: $e');
    }
  }
}
