import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:metenoxin_flutter/constants.dart';

class RedditTextHandler {
  Constants _constants = Constants();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  toRedditText({required Function(String) onStatusUpdate}) async {
    try {
      // Fetch the compared data
      final List<Map<String, dynamic>> jsonList = await getCompared();

      // for (var entry in jsonList.asMap().entries) {
      //   int i = entry.key; // The index of the current champ
      //   var champ = entry.value; // The champ itself

      //   onStatusUpdate(
      //       'name: ${champ["name"]}, points: ${champ["points"]}, rank: ${champ["rank"]}, change: ${champ["rankChange"]}');
      // }

      // Check if the list has entries
      if (jsonList.isNotEmpty) {
        // Create content using StringBuffer
        StringBuffer content = StringBuffer();
        content.writeln("__Champion Rank Points:__               ");
        content.writeln(
            "Picked +${_constants.points["picks"]} Point               ");
        content.writeln(
            "Banned +${_constants.points["bans"]} Point               ");
        content
            .writeln("Won +${_constants.points["wins"]} Points               ");
        content.writeln(
            "Loss ${_constants.points["loses"]} Points               ");
        content.writeln("&nbsp;");
        content.writeln("               ");

        content.writeln(
            "[Last Week](${_constants.previousWeekLink})               ");
        content.writeln("               ");
        content.writeln(
            "| Rank/Change | Points | Name | Star Player |               ");
        content.writeln("|-|-|-|-|               ");

        for (int i = 0; i < jsonList.length; i++) {
          var champion = jsonList[i];

          int championRank = champion['rank'] ?? 888888;
          String championName = champion['name'] ?? "hello";
          int championPoints = champion['points'] ?? 888888;
          String championRankChange = champion['rankChange'] ?? "hello";
          String topPlayerName = champion['starPlayer']['name'] ?? "hello";
          String topPlayerFlag = champion['starPlayer']['flag'] ?? "hello";
          String topPlayerWebsite =
              champion['starPlayer']['websiteUrl'] ?? "hello";

          content.writeln(
              "| $championRank $championRankChange | $championPoints | $championName | [$topPlayerFlag $topPlayerName]($topPlayerWebsite) |");
        }

        // Save content to clipboard
        Clipboard.setData(ClipboardData(text: content.toString()));
        onStatusUpdate('Text copied to clipboard successfully!');
      } else {
        onStatusUpdate('No entries found in the database.');
      }
    } catch (e) {
      onStatusUpdate('Error fetching data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCompared() async {
    try {
      // Reference to the document
      final docRef = _firestore.collection("champions").doc("compared");

      // Fetch the document
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Extract the 'data' field from the document
        final data = docSnapshot.data()?['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('No valid data field found in the document.');
        }
      } else {
        throw Exception('Document does not exist.');
      }
    } catch (e) {
      throw Exception('Error retrieving champion data from Firestore: $e');
    }
  }
}
