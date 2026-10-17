import 'dart:convert';
import 'package:flutter/services.dart';

class DatasetLoader {
  static const String assetPath = 'assets/data/starter_dataset.json';

  Future<Map<String, dynamic>> loadStarterData() async {
    final jsonString = await rootBundle.loadString(assetPath);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}
