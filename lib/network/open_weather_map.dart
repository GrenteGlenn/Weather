import 'dart:convert';

import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../constant/const.dart';
import '../models/fore_cast_result.dart';
import '../models/weather_result.dart';

class OpenWeatherMap {
  Future<WeatherResult> getWeather(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/weather?lat=${locationData.latitude}&lon=${locationData.longitude}&lang=fr&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return WeatherResult.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Mauvaise requête');
      }
    } else {
      throw Exception('Mauvaise localisation');
    }
  }
}

class OpenWeatherMapByCity {
  Future<WeatherResult> getWeatherByCity(String city) async {
    if (city != "") {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/weather?q=$city&lang=fr&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return WeatherResult.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Mauvaise requête');
      }
    } else {
      throw Exception('Mauvaise localisation');
    }
  }
}

class OpenWeatherMapForcast {
  Future<ForecastResult> getForecast(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/forecast?lat=${locationData.latitude}&lon=${locationData.longitude}&lang=fr&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return ForecastResult.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Mauvaise requête');
      }
    } else {
      throw Exception('Mauvaise localisation');
    }
  }
}