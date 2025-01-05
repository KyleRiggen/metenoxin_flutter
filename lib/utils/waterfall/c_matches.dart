import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/d_champs.dart';

class Matches {
  ApiCalls _apiCalls = ApiCalls();
  FirebaseService _firebase = FirebaseService();
  Constants constants = Constants();
  Champions _champions = Champions();

  Future<void> getMatches({
    required Function(String) onStatusUpdate,
    required String apiKey,
  }) async {
    try {
      onStatusUpdate("getting puuids");
      List<Map<String, String>> allPuuids = await _firebase.getPuuids();
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
      _firebase.saveMatchIds(matchIds: matchIdsList);
      onStatusUpdate("saved matches to firebase");
      _champions.getChamps(onStatusUpdate: onStatusUpdate, apiKey: apiKey);
    } catch (e) {
      onStatusUpdate("Error retrieving PUUIDs: $e");
    }
  }
}
