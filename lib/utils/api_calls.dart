import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiCalls {
  Future<dynamic>? basicApiCall({
    required String address,
    required String region,
    required String apiKey,
  }) async {
    final url =
        Uri.parse('https://$region.api.riotgames.com/$address?api_key=$apiKey');
    //print(url);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        print(url);
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<dynamic>? advancedApiCall({
    required String address,
    required String region,
    required String others,
    required String apiKey,
  }) async {
    final url = Uri.parse(
        'https://$region.api.riotgames.com/$address?$others&api_key=$apiKey');
    //print(url);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
