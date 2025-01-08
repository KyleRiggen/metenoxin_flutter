import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/api_calls.dart';
import 'package:metenoxin_flutter/utils/waterfall/e_points.dart';

class Champions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      List<String> matchDataList = await getMatchIds();
      final List<Map<String, dynamic>> setupChampData =
          await getListMap_setup(document: _constants.weekLabel);

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

        if (matchData != null) {
          var participants = matchData['info']['participants'];
          var teams = matchData['info']['teams'];

          participants.forEach((participant) {
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

                champ.putIfAbsent('players', () => <Map<String, dynamic>>[]);

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
      saveListMap_setup(
        data: setupChampData,
        document: _constants.weekLabel,
      );
      onStatusUpdate("Champion data successfully updated in Firestore.");
      _points.assignPoints(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error retrieving match data: $e");
    }
  }

  Future<List<String>> getMatchIds() async {
    try {
      // Get the document reference for the match IDs
      final docRef = _firestore.collection("players").doc("matchIds");
      final docSnapshot = await docRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // Extract the "matchIds" field
        final matchIdsData = data["matchIds"];

        // Ensure the "matchIds" field is not null and is a List
        if (matchIdsData != null && matchIdsData is List) {
          return List<String>.from(matchIdsData);
        } else {
          throw Exception("Field 'matchIds' is missing or not a list.");
        }
      } else {
        throw Exception("Document 'matchIds' does not exist in Firestore.");
      }
    } catch (e) {
      throw Exception('Error retrieving match IDs from Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getListMap_setup({
    required String document,
  }) async {
    try {
      // Reference to the main document
      final docRef = _firestore.collection("champions").doc(document);

      // Get the document snapshot
      final docSnapshot = await docRef.get();

      // Retrieve and return the 'data' field as a List<Map<String, dynamic>>
      if (docSnapshot.exists) {
        final data = docSnapshot.data()?['data'] as List<dynamic>?;

        if (data != null) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
        }
      }

      return [];
    } catch (e) {
      throw Exception('Error retrieving champion data from Firestore: $e');
    }
  }

  Future<void> saveListMap_setup({
    required List<Map<String, dynamic>> data,
    required String document,
  }) async {
    try {
      // Reference to the main document
      final docRef = _firestore.collection("champions").doc(document);

      // Create a map to store the champions with dynamic field names
      Map<String, dynamic> championsMap = {};

      // Loop through each champion and add it to the championsMap with a unique field name
      for (int i = 0; i < data.length; i++) {
        championsMap[data[i]["name"]] = data[i];
      }

      // Save the list and metadata to the document, including each champion as a separate field
      await docRef.set({
        "metadata": "Champ data collection",
        "a_savedAt": FieldValue.serverTimestamp(), // Add server timestamp
        "data": data, // Store the entire list as a field
        ...championsMap, // Spread the championsMap to add each champion as a new field
      });
    } catch (e) {
      throw Exception('Error saving champion data to Firestore: $e');
    }
  }
}
