import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/waterfall/d_champs.dart';

class Matches {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ApiCalls _apiCalls = ApiCalls();
  Constants constants = Constants();
  Champions _champions = Champions();

  Future<void> getMatches({
    required Function(String) onStatusUpdate,
    required String apiKey,
  }) async {
    try {
      onStatusUpdate("getting puuids");
      List<Map<String, String>> allPuuids = await getPuuids();
      onStatusUpdate("Retrieved ${allPuuids.length} puuids from firebase");

      int callCount = 0;
      Set<String> uniqueMatchIds = {};

      for (var entry in allPuuids) {
        // if (callCount >= constants.apiCallNumber) break;
        callCount++;

        String? puuid = entry['puuid'];
        String? region = entry['region'];
        String apiRegion = '';

        if (puuid == null || region == null) {
          onStatusUpdate("Invalid data in entry: $entry");
          continue;
        }

        if (region == 'na1') {
          apiRegion = 'americas';
        } else if (region == 'kr') {
          apiRegion = 'asia';
        } else if (region == 'euw1') {
          apiRegion = 'europe';
        } else {
          onStatusUpdate('error at region sorting in matches');
        }

        DateTime now = DateTime.now();
        int epochSeconds = now.toUtc().millisecondsSinceEpoch ~/ 1000;

        var data = await _apiCalls.advancedApiCall(
          address: "lol/match/v5/matches/by-puuid/$puuid/ids",
          region: apiRegion,
          others:
              "startTime=${epochSeconds - 604800}&endTime=$epochSeconds&type=ranked&start=0&count=100",
          apiKey: apiKey,
        );

        if (data != null) {
          onStatusUpdate(
              "$region: matchIDs=${uniqueMatchIds.length} $callCount/${allPuuids.length}");
          uniqueMatchIds.addAll(data.cast<String>());
        } else {
          onStatusUpdate("Failed to fetch match data for $entry");
        }
      }
      onStatusUpdate("saving to firebase");
      List<String> matchIdsList = uniqueMatchIds.toList();
      saveMatchIds(matchIds: matchIdsList);
      onStatusUpdate("saved matches to firebase");
      _champions.getChamps(onStatusUpdate: onStatusUpdate, apiKey: apiKey);
    } catch (e) {
      onStatusUpdate("Error retrieving PUUIDs: $e");
    }
  }

  Future<List<Map<String, String>>> getPuuids() async {
    try {
      // Get the document reference for the PUUIDs
      final docRef = _firestore.collection("players").doc("puuids");
      final docSnapshot = await docRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // Extract the "puuids" field
        final puuidsData = data["puuids"];

        // Ensure the "puuids" field is not null and is a List
        if (puuidsData != null && puuidsData is List) {
          // Convert each entry to Map<String, String>
          return puuidsData.map<Map<String, String>>((entry) {
            final entryMap =
                Map<String, String>.from(entry as Map<String, dynamic>);
            return entryMap;
          }).toList();
        } else {
          throw Exception("Field 'puuids' is missing or not a list.");
        }
      } else {
        throw Exception("Document 'puuids' does not exist in Firestore.");
      }
    } catch (e) {
      throw Exception('Error reading PUUIDs from Firestore: $e');
    }
  }

  Future<void> saveMatchIds({
    required List<String> matchIds,
  }) async {
    try {
      // Get the document reference for the match IDs
      final docRef = _firestore.collection("players").doc("matchIds");

      // Save the match IDs as a field in the document
      await docRef.set({
        "matchIds": matchIds,
      });
    } catch (e) {
      throw Exception('Error saving match IDs to Firestore: $e');
    }
  }
}
