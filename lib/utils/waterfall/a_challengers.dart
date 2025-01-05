import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/b_puuids.dart';

class Challengers {
  ApiCalls _apiCalls = ApiCalls();
  FirebaseService _firebase = FirebaseService();
  Constants constants = Constants();
  Puuids _puuids = Puuids();

  Future<void> callChallengers({
    required String apiKey,
    required Function(String) onStatusUpdate,
  }) async {
    try {
      onStatusUpdate("Starting to fetch challenger data...");

      for (String region in constants.regions) {
        var result = await _apiCalls.basicApiCall(
          address: "lol/league/v4/challengerleagues/by-queue/RANKED_SOLO_5x5",
          region: region,
          apiKey: apiKey,
        );

        List<Map<String, dynamic>> entries;
        if (result != null && result.containsKey("entries")) {
          entries = List<Map<String, dynamic>>.from(result["entries"]);
        } else {
          onStatusUpdate("No entries found in challenger data.");
          return;
        }

        onStatusUpdate(
            "Successfully retrieved ${entries.length} challengers from ${region}");
        await _firebase.saveListMap_challengers(
          data: entries,
          region: region,
        );
        onStatusUpdate("saving ${region} to firebase");
      }

      onStatusUpdate("Challenger data successfully saved in Firebase.");
      _puuids.callChallengers(apiKey: apiKey, onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error fetching challenger data: $e");
      throw Exception('Error fetching challenger data: $e');
    }
  }
}
