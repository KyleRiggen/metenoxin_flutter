import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/waterfall/g_text.dart';

class Compare {
  Constants _constants = Constants();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RedditTextHandler _text = RedditTextHandler();

  Future<void> compareFromLastWeek(
      {required Function(String) onStatusUpdate}) async {
    try {
      onStatusUpdate("-----------------------");
      List<Map<String, dynamic>> lastWeekChampList =
          await getChampsList(document: _constants.lastWeekLabel);
      List<Map<String, dynamic>> champsList =
          await getChampsList(document: _constants.weekLabel);

      champsList.sort((a, b) {
        final pointsA = a['points'] ?? 0; // Default to 0 if points are missing
        final pointsB = b['points'] ?? 0; // Default to 0 if points are missing
        return pointsB.compareTo(pointsA); // Sort in descending order
      });

      Map<String, int> oldPositions = {
        for (var i = 0; i < lastWeekChampList.length; i++)
          lastWeekChampList[i]['key']: i
      };
      Map<String, int> newPositions = {
        for (var i = 0; i < champsList.length; i++) champsList[i]['key']: i
      };

      List<Map<String, dynamic>> championsData = [];
      // Add rank change field to each champ in champsList
      for (var entry in champsList.asMap().entries) {
        int i = entry.key; // The index of the current champ
        var champ = entry.value; // The champ itself

        String championKey = champ['key'];
        String championName = champ['name'];
        int championPoints = champ['points'];

        int oldRank =
            oldPositions[championKey] ?? -1; // Default to -1 if not found
        int newRank =
            newPositions[championKey] ?? -1; // Default to -1 if not found
        int rankChange = oldRank - newRank;

        String rankChangeText = "";
        if (rankChange > 0) {
          rankChangeText = "🟩🔺$rankChange";
        } else if (rankChange < 0) {
          rankChangeText = "🟥🔻${rankChange.abs()}";
        } else {
          rankChangeText = "🟨0";
        }

        var topPlayer =
            champ['players']?.isNotEmpty == true ? champ['players'][0] : null;
        String topPlayerName = topPlayer?['riotIdGameName'] ?? 'No players';
        String topPlayerTagline = topPlayer?['riotIdTagline'] ?? '';
        String topPlayerRegion = topPlayer?['region'] ?? '';
        String websiteRegion = {
              'NA1': 'na',
              'KR': 'kr',
              'EUW1': 'euw',
            }[topPlayerRegion] ??
            'unknown';
        String regionFlag = {
              'NA1': '🇺🇸',
              'KR': '🇰🇷',
              'EUW1': '🇪🇺',
            }[topPlayerRegion] ??
            '🏴‍☠️';
        final encodedName = Uri.encodeComponent(topPlayerName);
        final encodedTagline = Uri.encodeComponent(topPlayerTagline);

        championsData.add({
          'rank': i + 1,
          'points': championPoints,
          'name': championName,
          'rankChange': rankChangeText,
          'starPlayer': {
            'name': topPlayerName,
            'flag': regionFlag,
            'websiteUrl':
                'https://www.op.gg/summoners/$websiteRegion/$encodedName-$encodedTagline',
          }
        });
      }

      saveCompared(data: championsData);
      _text.toRedditText(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error compairing: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllChampions({
    required String document,
  }) async {
    try {
      // Reference to the document in Firestore
      final docRef = _firestore.collection("champions").doc(document);

      // Fetch the document data
      final docSnapshot = await docRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Get the data from the document
        Map<String, dynamic> docData =
            docSnapshot.data() as Map<String, dynamic>;

        // Extract the champions data, excluding the 'metadata' and 'a_savedAt' fields
        List<Map<String, dynamic>> champions = [];

        // Iterate over the fields and gather the champion data
        docData.forEach((key, value) {
          // Skip the metadata and timestamp fields
          if (key != 'metadata' && key != 'a_savedAt' && key != 'data') {
            champions.add(value); // Add champion data to the list
          }
        });

        return champions;
      } else {
        throw Exception('Document does not exist.');
      }
    } catch (e) {
      throw Exception('Error retrieving champion data from Firestore: $e');
    }
  }

  Future<void> saveCompared({
    required List<Map<String, dynamic>> data,
    // required String document,
  }) async {
    try {
      // Reference to the main document
      final docRef = _firestore.collection("champions").doc("compared");

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

  Future<List<Map<String, dynamic>>> getChampsList(
      {required String document}) async {
    try {
      // Get the document reference for the specific region
      final docRef = _firestore.collection("champions").doc(document);
      final docSnapshot = await docRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final challengersData = data["data"];

        // If the challengers data exists, return it
        if (challengersData != null) {
          return List<Map<String, dynamic>>.from(challengersData);
        } else {
          throw Exception("champion data not found in Firestore.");
        }
      } else {
        throw Exception("Region document does not exist in Firestore.");
      }
    } catch (e) {
      throw Exception('Error reading challenger data from Firestore: $e');
    }
  }
}
