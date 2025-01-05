import 'package:flutter/services.dart';
import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';

class RedditTextHandler {
  Constants _constants = Constants();
  FirebaseService _firestore = FirebaseService();

  toRedditText({required Function(String) onStatusUpdate}) async {
    try {
      onStatusUpdate('line11');
      // Fetch the compared data
      final List<Map<String, dynamic>> jsonList =
          await _firestore.getCompared();
      onStatusUpdate('line15');

      // Check if the list has entries
      if (jsonList.isNotEmpty) {
        onStatusUpdate('line19');
        // Create content using StringBuffer
        StringBuffer content = StringBuffer();
        content.writeln("__Champion Rank Points:__");
        content.writeln("Picked +${_constants.points["picks"]} Point");
        content.writeln("Banned +${_constants.points["bans"]} Point");
        content.writeln("Won +${_constants.points["wins"]} Points");
        content.writeln("Loss ${_constants.points["loses"]} Points");
        content.writeln("&nbsp;");
        content.writeln("");
        onStatusUpdate('line29');

        content.writeln("[Last Week](${_constants.previousWeekLink})");
        content.writeln("");
        content.writeln("| Rank/Change | Points | Name | Star Player |");
        content.writeln("|-|-|-|-|");
        onStatusUpdate('line35');

        for (int i = 0; i < jsonList.length; i++) {
          var champion = jsonList[i];
          onStatusUpdate('line39');

          int championRank = champion['rank'];
          String championName = champion['name'];
          int championPoints = champion['points'];
          // String championRankChange = champion['rankChange'];
          String topPlayerName = champion['starPlayer']['name'];
          String topPlayerFlag = champion['starPlayer']['flag'];
          String topPlayerWebsite = champion['starPlayer']['websiteUrl'];
          onStatusUpdate('line48');

          content.writeln(
              "| $championRank | $championPoints | $championName | [$topPlayerFlag $topPlayerName]($topPlayerWebsite) |");
        }
        onStatusUpdate('line53');

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
}
