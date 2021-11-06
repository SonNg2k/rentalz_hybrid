import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rentalz/constants/secrets.dart';
import 'package:rentalz/models/gmp_service/gmp_place_autocomplete.model.dart';

/// Google Place Autocomplete API returns up to 5 results
Future<List<GoogleMapsPlaceAutocomplete>> predictSimilarPlaces(
    String input) async {
  if (input.length <= 2) return [];
  final placeAutocompleteAPI = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/autocomplete/json',
    {
      'key': googleMapsApiKey,
      'input': input,
      'components': 'country:vn',
    },
  );
  final response = await http.get(placeAutocompleteAPI);
  if (response.statusCode == 200) {
    final parsed = (json.decode(response.body)['predictions'] as List)
        .cast<Map<String, dynamic>>();
    return parsed
        .map<GoogleMapsPlaceAutocomplete>(
            (json) => GoogleMapsPlaceAutocomplete.fromJson(json))
        .toList();
  } else {
    throw HttpException(
      'The place prediction service is unavailable',
      uri: placeAutocompleteAPI,
    );
  }
}
