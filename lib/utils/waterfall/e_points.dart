import 'package:metenoxin_flutter/constants.dart';
import 'package:metenoxin_flutter/utils/firebase.dart';
import 'package:metenoxin_flutter/utils/waterfall/f_compare.dart';

class Points {
  FirebaseService _firestore = FirebaseService();
  Constants _constants = Constants();
  Compare _compare = Compare();

  assignPoints({required Function(String) onStatusUpdate}) async {
    try {
      List<Map<String, dynamic>> setupDataList =
          await _firestore.getListMap_setup(document: _constants.new_document);

      if (setupDataList.isEmpty) {
        onStatusUpdate("No champion data available to process.");
        return;
      }

      for (Map<String, dynamic> champ in setupDataList) {
        int updatedPoints = (champ["kills"] * _constants.points["kills"]!) +
            (champ["wins"] * _constants.points["wins"]!) +
            (champ["loses"] * _constants.points["loses"]!) +
            (champ["picks"] * _constants.points["picks"]!) +
            (champ["bans"] * _constants.points["bans"]!);

        champ["points"] = updatedPoints;

        // onStatusUpdate(
        //     "Processing champion: ${champ['name']} - Updated Points: $updatedPoints");

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
      }

      setupDataList.sort((a, b) {
        final pointsA = (a['points'] ?? 0) as num;
        final pointsB = (b['points'] ?? 0) as num;
        return (pointsB.compareTo(pointsA));
      });
      await _firestore.saveListMap_setup(
          data: setupDataList, document: _constants.new_document);
      onStatusUpdate(
          "Champion data successfully updated in Firestore with points.");
      _compare.compareFromLastWeek(onStatusUpdate: onStatusUpdate);
    } catch (e) {
      onStatusUpdate("Error in processing champion data: $e");
    }
  }
}
