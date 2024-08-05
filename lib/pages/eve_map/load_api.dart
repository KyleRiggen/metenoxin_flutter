import 'package:http/http.dart' as http;
import 'dart:convert';

class LoadApi {
  // https://esi.evetech.net/dev/markets/10000002/orders/?datasource=tranquility&order_type=sell&page=1&type_id=81826
  // https://esi.evetech.net/ui/?version=dev#/Market/get_markets_region_id_orders
  Future<double?> loadApi() async {
    try {
      final response = await http.get(Uri.parse(
          'https://esi.evetech.net/dev/markets/10000002/orders/?datasource=tranquility&order_type=sell&page=1&type_id=62457'));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = jsonDecode(response.body);
        // Sort the data by adjusted_price in ascending order
        data.sort((a, b) {
          double priceA = a['price'] ?? double.infinity;
          double priceB = b['price'] ?? double.infinity;
          return priceA.compareTo(priceB);
        });

        // Find the minimum price
        double cheapestPrice = data
            .map((item) => item['price'] as double)
            .reduce((a, b) => a < b ? a : b);

        print(cheapestPrice);

        return cheapestPrice;
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
