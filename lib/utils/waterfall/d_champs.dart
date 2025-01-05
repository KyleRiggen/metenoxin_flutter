import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/e_points.dart';

class Champions {
  FirebaseService _firestore = FirebaseService();
  Constants _constants = Constants();
  ApiCalls _apiCalls = ApiCalls();
  Points _points = Points();

  Future<void> getChamps({
    required Function(String) onStatusUpdate,
    required String apiKey,
  }) async {
    int matchCounter = 0;
    try {
      // Retrieve match IDs from Firestore
      List<String> matchDataList = await _firestore.getMatchIds();
      final List<Map<String, dynamic>> setupChampData =
          await _firestore.getListMap_setup(document: _constants.new_document);

      onStatusUpdate("matches from firebase ${matchDataList.length}");
      onStatusUpdate("champs from firebase ${setupChampData.length}");
      for (String matchId in matchDataList) {
        if (matchCounter >= (_constants.apiCallNumber * 3)) break;
        matchCounter++;
        onStatusUpdate(
            'Processing match ID: $matchId, $matchCounter of ${matchDataList.length}');

        String region = matchId.split('_')[0];

        String websiteRegion = {
              'NA1': 'americas',
              'KR': 'asia',
              'EUW1': 'europe',
            }[region] ??
            'unknown';

        var matchData = await _apiCalls.basicApiCall(
          address: "lol/match/v5/matches/$matchId",
          region: websiteRegion,
          apiKey: apiKey,
        );
        await Future.delayed(Duration(milliseconds: 500));

        if (matchData != null) {
          var participants = matchData['info']['participants'];
          var teams = matchData['info']['teams'];

          participants.forEach((participant) {
            // onStatusUpdate(
            //     'Processing champ ID: ${participant['championName']} of ${setupChampData.length}');
            String championKey = participant['championId'].toString();
            int kills = participant['kills'] ?? 0;
            int deaths = participant['deaths'] ?? 0;
            int assists = participant['assists'] ?? 0;
            bool win = participant['win'];

            String riotIdGameName = participant['riotIdGameName'];
            String riotIdTagline = participant['riotIdTagline'];

            for (var champ in setupChampData) {
              if (champ['key'] == championKey) {
                champ['picks'] = (champ['picks'] ?? 0) + 1;
                champ['kills'] = (champ['kills'] ?? 0) + kills;
                champ['deaths'] = (champ['deaths'] ?? 0) + deaths;
                champ['assists'] = (champ['assists'] ?? 0) + assists;
                champ['wins'] =
                    win ? (champ['wins'] ?? 0) + 1 : (champ['wins'] ?? 0);
                champ['loses'] =
                    win ? (champ['loses'] ?? 0) : (champ['loses'] ?? 0) + 1;

                // Initialize 'players' if it doesn't exist
                champ.putIfAbsent('players', () => <Map<String, dynamic>>[]);

                // Check if the player already exists in the 'players' array
                var existingPlayer = champ['players'].firstWhere(
                  (player) =>
                      player['riotIdGameName'] == riotIdGameName &&
                      player['riotIdTagline'] == riotIdTagline &&
                      player['region'] == region,
                  orElse: () => null,
                );

                if (existingPlayer != null) {
                  // Update the existing player's stats
                  existingPlayer['kills'] += kills;
                  existingPlayer['deaths'] += deaths;
                  existingPlayer['assists'] += assists;
                  existingPlayer['picks'] = (existingPlayer['picks'] ?? 0) + 1;
                } else {
                  // Add new player entry if they don't exist
                  champ['players'].add({
                    'riotIdGameName': riotIdGameName,
                    'riotIdTagline': riotIdTagline,
                    'region': region,
                    'kills': kills,
                    'deaths': deaths,
                    'assists': assists,
                    'picks': 1,
                  });
                }
                break;
              }
            }
          });

          teams.forEach((team) {
            var bans = team['bans'];

            bans.forEach((ban) {
              String championKey = ban['championId'].toString();
              for (var champ in setupChampData) {
                if (champ['key'] == championKey) {
                  champ['bans'] = (champ['bans'] ?? 0) + 1;
                  break;
                }
              }
            });
          });
        }
      }
      await _firestore.saveListMap_setup(
          data: setupChampData, document: _constants.new_document);
      onStatusUpdate("Champion data successfully updated in Firestore.");
      _points.assignPoints(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error retrieving match data: $e");
    }
  }
}
