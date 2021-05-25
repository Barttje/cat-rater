import 'dart:convert';

import 'package:cat_tinder/model/Cat.dart';
import 'package:http/http.dart' as http;

class CatRepository {
  Future<Cat> fetchCat() async {
    final response = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/images/search'),
      headers: {"x-api-key": "api-key", "Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return Cat.fromJson(jsonDecode(response.body)[0]);
    } else {
      throw Exception('Failed to load Cat');
    }
  }
}
