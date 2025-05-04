import 'package:get/get.dart';
import 'package:location/location.dart';
import '../models/weather_result.dart';


class MyStateController {
  final isEnableLocation = false.obs;
  final locationData = LocationData.fromMap(<String, dynamic>{}).obs;

  final isLoading = false.obs;

  WeatherResult? weatherResult;

  void updateWeatherData(WeatherResult weatherData) {
    weatherResult = weatherData;


  }
}
