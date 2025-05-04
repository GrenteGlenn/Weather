import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constant/const.dart';
import '../icons/icons.dart';
import '../models/data_day_result.dart' as DataDayResult;
import '../models/next_days.dart' as Nextdays;
import '../state/state.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DailyDataForecast extends StatelessWidget {
  final controller = Get.put(MyStateController());
  final Nextdays.Nextdays nextDaysData;
  final bool isCelsius;


  int celsiusToFahrenheit(int celsius) {
    return (celsius * 9 ~/ 5) + 32;
  }

  DailyDataForecast({Key? key, required this.nextDaysData, required this.isCelsius}) : super(key: key);

  String getDay(int? day) {
    if (day != null) {
      DateTime time = DateTime.fromMillisecondsSinceEpoch(day * 1000);
      final x = DateFormat('EEEEE').format(time);
      return x;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('fr', null);
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            child: const Text(
              "Jours suivants",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          FutureBuilder<DataDayResult.DayliResult>(
            future: getForecast(controller.locationData.value),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    'Pas de données',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                final data = snapshot.data!;
                return dailyList(data);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget dailyList(DataDayResult.DayliResult dayliResult) {
    // List unique day
    List<int> uniqueDays = [];
    List<String> displayedDays = [];
    // ignore: unused_local_variable
    List<String> dayName = [];

    dayliResult.list?.forEach((forecast) {
      DateTime forecastTime =
          DateTime.fromMillisecondsSinceEpoch(forecast.dt! * 1000);
      String dayString = DateFormat.EEEE('fr').format(forecastTime);
      int day = forecastTime.day;

      if (!displayedDays.contains(dayString) &&
          DateTime.now().isBefore(forecastTime)) {
        displayedDays.add(dayString);
        uniqueDays.add(day);
      }
    });

    DateTime now = DateTime.now();
    int currentDay = now.day;

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: uniqueDays.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.white,
          thickness: 2,
        ),
        itemBuilder: (context, index) {
          // if condition match with currentDay, return a void widget
          // For don't display currentDay on list
          if (uniqueDays[index] == currentDay) {
            return const SizedBox.shrink();
          }
          // Filter data for each day match as index
          List<DataDayResult.ListDataDaily> filteredForecasts = dayliResult
              .list!
              .where((forecast) {
                DateTime forecastTime =
                    DateTime.fromMillisecondsSinceEpoch(forecast.dt! * 1000);
                int day = forecastTime.day;
                return day == uniqueDays[index] &&
                    DateTime.now().isBefore(forecastTime);
              })
              .take(5)
              .toList();

          int maxTemperature = filteredForecasts
              .map((forecast) => forecast.main!.tempMax!)
              .reduce((a, b) => a > b ? a : b);

          int minTemperature = filteredForecasts
              .map((forecast) => forecast.main!.tempMin!)
              .reduce((a, b) => a < b ? a : b);

          // filter data for firstday as today
          DataDayResult.ListDataDaily firstForecast = filteredForecasts.first;
          // Change language day for french
          String dayName = DateFormat.EEEE('fr').format(
              (DateTime.fromMillisecondsSinceEpoch(firstForecast.dt! * 1000)));

          return Column(
            children: [
              Container(
                height: 45,
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 200,
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.network(
                          buildIcon(firstForecast.weather![0].icon ?? ''),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isCelsius
                              ? "${celsiusToFahrenheit(minTemperature)}°/ ${celsiusToFahrenheit(maxTemperature)}°F"
                              : "$minTemperature°/$maxTemperature°C",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<DataDayResult.DayliResult> getForecast(
      LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/forecast?lat=${locationData.latitude}&lon=${locationData.longitude}&lang=fr&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return DataDayResult.DayliResult.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Mauvaise requête');
      }
    } else {
      throw Exception('Mauvaise localisation');
    }
  }
}