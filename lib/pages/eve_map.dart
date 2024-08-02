import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EveMap extends StatefulWidget {
  const EveMap({super.key});

  @override
  State<EveMap> createState() => _EveMapState();
}

class _EveMapState extends State<EveMap> {
  List<dynamic>? jsonData;

  Future<void> loadJsonAsset() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/moons.json');

      final List<dynamic> data = jsonDecode(jsonString);

      // Ensure the data is a list of maps
      // final List<Map<String, dynamic>> parsedData =
      //     data.map((item) => item as Map<String, dynamic>).toList();
      // print(parsedData);
      setState(() {
        jsonData = data;
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }

    // final String jsonString = await rootBundle.loadString('assets/data.json');
    // final data = jsonDecode(jsonString);
    // print(data);
    // setState(() {
    //   jsonData = data;
    // });
  }

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

  String formatComposition(List<dynamic> composition) {
    return composition.map((item) {
      double percent = (item['percent'] as num).toDouble();
      return "${item['name']}: ${(percent * 100).toStringAsFixed(2)}%";
    }).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    // print(jsonData);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eve Moons'),
      ),
      body: Center(
        child: jsonData != null
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Region')),
                    DataColumn(label: Text('Moon')),
                    DataColumn(label: Text('Composition')),
                  ],
                  rows: jsonData!.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item['region'])),
                        DataCell(Text(item['moon'])),
                        DataCell(Text(formatComposition(
                            item['composition'] as List<dynamic>))),
                      ],
                    );
                  }).toList(),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
