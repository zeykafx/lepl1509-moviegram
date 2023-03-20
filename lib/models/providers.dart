import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http;
import 'package:projet_lepl1509_groupe_17/main.dart';

class Provider {
  final int id;
  final Map<String, dynamic> countryProviders;

  Provider({required this.id, required this.countryProviders});

  static Future<Provider?> getProvider(int movieId) async {
    Provider? provider;
    var response = await http.get(Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$themoviedbApi"));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      provider = Provider.fromJson(jsonResponse);
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    return provider;
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      countryProviders: json['results'],
    );
  }
}

class ProviderCountry {
  final int id;
  final String name;
  final String logoPath;

  ProviderCountry({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  static getProviderCountry(Map<String, dynamic> map) {
    return ProviderCountry(
      id: map['provider_id'],
      name: map['provider_name'],
      logoPath: map['logo_path'],
    );
  }
}
