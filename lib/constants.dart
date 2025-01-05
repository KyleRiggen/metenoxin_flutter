class Constants {
  List<String> regions = ['na1', 'kr', 'euw1'];

  int apiCallNumber = 2;

  int streakNumber = 3;

  String new_document = "new-champs";
  String old_document = "old-champs";
  List previousWeekPaths = [];
  String previousWeekLink =
      "https://www.reddit.com/r/doubloonin/comments/1hgwspe/league_of_legends_champion_popularityperformance/";

  Map<String, int> points = {
    "picks": 1,
    "bans": 1,
    "kills": 2,
    "deaths": -2,
    "assists": 1,
    "wins": 2,
    "loses": -2
  };
}
