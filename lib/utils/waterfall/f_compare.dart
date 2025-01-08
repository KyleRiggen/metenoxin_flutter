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
      List<Map<String, dynamic>> champsList =
          await getChampsList(document: _constants.weekLabel);

      onStatusUpdate("champs gotten to compare: ${champsList.length}");

      // // Create ranking maps (old vs new rank)
      // final Map<String, int> oldRanks = {
      //   for (int i = 0; i < oldList.length; i++) oldList[i]['key']: i + 1,
      // };

      // final Map<String, int> newRanks = {
      //   for (int i = 0; i < newList.length; i++) newList[i]['key']: i + 1,
      // };

      // Sort champions by points in descending order
      champsList.sort((a, b) {
        final pointsA = a['points'] ?? 0; // Default to 0 if points are missing
        final pointsB = b['points'] ?? 0; // Default to 0 if points are missing
        return pointsB.compareTo(pointsA); // Sort in descending order
      });

      onStatusUpdate("champs sorted to compare: ${champsList.length}");

      List<Map<String, dynamic>> championsData = [];
      for (int i = 0; i < champsList.length; i++) {
        var champion = champsList[i];
        String championKey = champion['key'];
        String championName = champion['name'];
        int championPoints = champion['points'];

        // // Calculate rank change
        // var oldRank =
        //     oldRanks[championKey] ?? oldList.length + 1; // Default to last+1
        // var newRank =
        //     newRanks[championKey] ?? newList.length + 1; // Default to last+1
        // var rankChange = oldRank - newRank;

        // String rankChangeText = "";
        // if (rankChange > 0) {
        //   rankChangeText = "🟩🔺$rankChange";
        // } else if (rankChange < 0) {
        //   rankChangeText = "🟥🔻${rankChange.abs()}";
        // } else {
        //   rankChangeText = "🟨0";
        // }

        // Handle current week's star player
        var topPlayer = champion['players']?.isNotEmpty == true
            ? champion['players'][0]
            : null;
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

        // Encode player name for URL
        final encodedName = Uri.encodeComponent(topPlayerName);
        final encodedTagline = Uri.encodeComponent(topPlayerTagline);

        // Add champion data with streak count, star player information, and flag
        championsData.add({
          'rank': i + 1,
          'points': championPoints,
          'name': championName,
          //'rankChange': rankChangeText,
          'starPlayer': {
            'name': topPlayerName,
            'flag': regionFlag, // New flag emoji field
            'websiteUrl':
                'https://www.op.gg/summoners/$websiteRegion/$encodedName-$encodedTagline',
          }
        });
      }
      await saveCompared(data: championsData);
      onStatusUpdate("Compared data successfully updated in Firestore.");
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
