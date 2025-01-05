import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/c_matches.dart';

class Puuids {
  ApiCalls _apiCalls = ApiCalls();
  FirebaseService _firebase = FirebaseService();
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
            await _firebase.getChallengers(region: region);

        onStatusUpdate("$region from firebase");
        int callCount = 0;
        for (var player in challengersData) {
          if (callCount >= constants.apiCallNumber) {
            // Replace 100 with your desired limit
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

            puuids.add({'region': region, 'puuid': result['puuid']});
            callCount++;
            onStatusUpdate(
                "$region puuids=${puuids.length}  $callCount/${challengersData.length}");
            await Future.delayed(Duration(milliseconds: 500));
          } catch (apiError) {
            onStatusUpdate(
                "Error fetching data for player ${player["summonerId"]} in region $region: $apiError");
            continue; // Log error and continue with the next player
          }
        }
      }
      onStatusUpdate("saving puuids to db");
      _firebase.savePuuids(puuids: puuids);
      onStatusUpdate("saved puuids to db");
      _matches.getMatches(onStatusUpdate: onStatusUpdate, apiKey: apiKey);
      onStatusUpdate("called matches");
    } catch (e) {
      onStatusUpdate("Error fetching challenger data: $e");
      throw Exception('Error fetching challenger data: $e');
    }
  }
}
