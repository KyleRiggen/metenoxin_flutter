import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/waterfall/f_compare.dart';

class Points {
  Constants _constants = Constants();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Compare _compare = Compare();

  assignPoints({required Function(String) onStatusUpdate}) async {
    try {
      List<Map<String, dynamic>> champsList =
          await getAllChampions(document: _constants.weekLabel);
      onStatusUpdate("champs gotten: ${champsList.length}");

      if (champsList.isEmpty) {
        onStatusUpdate("No champion data available to process.");
        return;
      }

      for (Map<String, dynamic> champ in champsList) {
        // Calculate points for the champion
        int updatedPoints = (champ["kills"] * _constants.points["kills"]!) +
            (champ["wins"] * _constants.points["wins"]!) +
            (champ["loses"] * _constants.points["loses"]!) +
            (champ["picks"] * _constants.points["picks"]!) +
            (champ["bans"] * _constants.points["bans"]!);

        champ["points"] = updatedPoints;

        for (var player in champ['players']) {
          player['points'] = (player['kills'] * _constants.points['kills']!) +
              (player['deaths'] * _constants.points['deaths']!) +
              (player['assists'] * _constants.points['assists']!);
        }
        champ['players'].sort((a, b) {
          final pointsA = (a['points'] ?? 0) as num;
          final pointsB = (b['points'] ?? 0) as num;
          return (pointsB.compareTo(pointsA));
        });

        // Optionally update the status
        onStatusUpdate(
            "Champion: ${champ['name']} - Updated Points: $updatedPoints");
      }

      // Save updated champions data back to Firestore
      await saveUpdatedChampionsToFirestore(champsList);

      onStatusUpdate(
          "Champion data successfully updated in Firestore with points.");
      _compare.compareFromLastWeek(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error in processing champion data: $e");
    }
  }

  Future<void> saveUpdatedChampionsToFirestore(
      List<Map<String, dynamic>> champsList) async {
    try {
      // Reference to the Firestore collection and document
      final docRef =
          _firestore.collection("champions").doc(_constants.weekLabel);

      // Create a map of champions data to save
      Map<String, dynamic> updatedData = {
        "metadata": "Updated champion data with points",
        "a_savedAt": FieldValue.serverTimestamp(),
        "data": champsList, // Store the updated champion list
      };

      // Update the document with the new data
      await docRef.set(updatedData);
    } catch (e) {
      throw Exception('Error saving updated champion data to Firestore: $e');
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
}
