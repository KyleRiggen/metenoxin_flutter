class Constants {
  List<String> regions = ['na1', 'kr', 'euw1'];

  int apiCallNumber = 1;

  int streakNumber = 3;

  String previousWeekPath = "lib/previous_weeks/dec1.json";
  List previousWeekPaths = [];
  String previousWeekLink =
      "https://www.reddit.com/r/doubloonin/comments/1h3s1z8/league_of_legends_champion_popularityperformance/";

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
