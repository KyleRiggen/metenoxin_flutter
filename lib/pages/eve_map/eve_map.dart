import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:metenoxin_flutter/pages/eve_map/load_api.dart';

class EveMap extends StatefulWidget {
  const EveMap({super.key});

  @override
  _EveMapState createState() => _EveMapState();
}

class _EveMapState extends State<EveMap> {
  List<dynamic>? jsonData;
  List<dynamic>? oreData;
  List<bool> _isHovering = [];
  double? cheapestPrice;

  @override
  void initState() {
    super.initState();
    loadMoonsAsset();
    loadOreAsset();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final api = LoadApi();
    final price = await api.loadApi();
    if (mounted) {
      setState(() {
        cheapestPrice = price;
      });
    }
  }

  Future<void> loadMoonsAsset() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/moons.json');
      final List<dynamic> data = jsonDecode(jsonString);
      if (mounted) {
        setState(() {
          jsonData = data;
          _isHovering = List<bool>.filled(data.length, false);
        });
      }
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  Future<void> loadOreAsset() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/ore_data.json');
      final List<dynamic> data = jsonDecode(jsonString);
      if (mounted) {
        setState(() {
          oreData = data;
          _isHovering = List<bool>.filled(data.length, false);
        });
      }
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  String formatComposition(List<dynamic> composition) {
    return composition.map((item) {
      double percent = (item['percent'] as num).toDouble();
      return "${item['name']}: ${(percent * 100).toStringAsFixed(2)}%";
    }).join(", ");
  }

  @override
  Widget build(BuildContext context) {
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
                    DataColumn(label: Text('Value')),
                  ],
                  rows: List<DataRow>.generate(
                    jsonData!.length,
                    (index) {
                      final item = jsonData![index];
                      final ore = oreData![index];
                      return DataRow(
                        cells: [
                          DataCell(Text(item['region'])),
                          DataCell(Text(item['moon'])),
                          DataCell(Text(formatComposition(
                              item['composition'] as List<dynamic>))),
                          DataCell(
                            MouseRegion(
                              onEnter: (_) => setState(() {
                                _isHovering[index] = true;
                              }),
                              onExit: (_) => setState(() {
                                _isHovering[index] = false;
                              }),
                              child: Container(
                                color: _isHovering[index]
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.transparent,
                                child: Text(ore['price'].toString()),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
