import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/g_text.dart';

class Compare {
  Constants _constants = Constants();
  FirebaseService _firestore = FirebaseService();
  RedditTextHandler _text = RedditTextHandler();

  Future<void> compareFromLastWeek(
      {required Function(String) onStatusUpdate}) async {
    try {
      final List<Map<String, dynamic>> newList =
          await _firestore.getListMap_setup(document: _constants.new_document);
      final List<Map<String, dynamic>> oldList = await _firestore
          .getListMap_setup_old(document: _constants.old_document);

      // Create ranking maps (old vs new rank)
      final Map<String, int> oldRanks = {
        for (int i = 0; i < oldList.length; i++) oldList[i]['key']: i + 1,
      };

      final Map<String, int> newRanks = {
        for (int i = 0; i < newList.length; i++) newList[i]['key']: i + 1,
      };

      List<Map<String, dynamic>> championsData = [];
      for (int i = 0; i < newList.length; i++) {
        var champion = newList[i];
        String championKey = champion['key'];
        String championName = champion['name'];
        int championPoints = champion['points'];

        // Calculate rank change
        var oldRank =
            oldRanks[championKey] ?? oldList.length + 1; // Default to last+1
        var newRank =
            newRanks[championKey] ?? newList.length + 1; // Default to last+1
        var rankChange = oldRank - newRank;

        String rankChangeText = "";
        if (rankChange > 0) {
          rankChangeText = "🟩🔺$rankChange";
        } else if (rankChange < 0) {
          rankChangeText = "🟥🔻${rankChange.abs()}";
        } else {
          rankChangeText = "🟨0";
        }

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
          'rank': newRank,
          'points': championPoints,
          'name': championName,
          'rankChange': rankChangeText,
          'starPlayer': {
            'name': topPlayerName,
            'flag': regionFlag, // New flag emoji field
            'websiteUrl':
                'https://www.op.gg/summoners/$websiteRegion/$encodedName-$encodedTagline',
          }
        });
      }
      await _firestore.saveCompared(data: championsData);
      onStatusUpdate("Compared data successfully updated in Firestore.");
      _text.toRedditText(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error compairing: $e");
    }
  }
}
