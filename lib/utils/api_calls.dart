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
    try {
      await Future.delayed(Duration(milliseconds: 1000));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // If the status code is not 200, print the status code and the URL
        print('Failed to fetch data: ${response.statusCode}');
        print(url);
        return null;
      }
    } catch (e) {
      // Catch errors (e.g., network issues or request errors) and print the error message
      print('Error in basic API call: $e');
      if (e is http.Response) {
        print('Status Code: ${e.statusCode}');
      } else {
        // If it's not an HTTP response-related error, just print the error message
        print('Exception details: $e');
      }
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
      await Future.delayed(Duration(milliseconds: 1000));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in advanced: $e');
      return null;
    }
  }
}
