import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:theweather/icons/icons.dart';
import 'package:theweather/models/weather_result.dart';
import 'package:theweather/widgets/info_widget.dart';

class WeatherTile extends StatelessWidget {
  final BuildContext? context;
  final WeatherResult data;
  final double? titleFontSize;
  final String? subTitle;
  final bool isCelsius;
  final int Function(int) convert;

  const WeatherTile(
      {Key? key,
      this.context,
      required this.data,
      this.titleFontSize,
      this.subTitle,
      required this.convert,
      required this.isCelsius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topCenter,
          child: Text(
            data.name ?? '',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topCenter,
          child: Text(
            subTitle ?? '',
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: buildIcon(data.weather![0].icon ?? ''),
                height: 100,
                width: 100,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, err) => const Icon(
                  Icons.image,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 50), // space between image and temp
              Text(
                  isCelsius
                      ? '${convert(data.main!.temp!.toInt())}°F'
                      : '${data.main!.temp}°C ',
                  style: const TextStyle(fontSize: 35, color: Colors.white))
            ],
          ),
        ),
        Center(
          child: Text(
            data.weather![0].description ?? '',
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 8,
            ),
            InfoWidget(
                icon: FontAwesomeIcons.wind, text: '${data.wind!.speed}%'),
            InfoWidget(
                icon: FontAwesomeIcons.cloud, text: '${data.clouds!.all}%'),
            InfoWidget(
                icon: FontAwesomeIcons.droplet, text: '${data.main!.humidity}%'),
            InfoWidget(
                icon: FontAwesomeIcons.snowflake,
                text: data.snow != null ? '${data.snow!.d1h}%' : '0'),
            SizedBox(
              width: MediaQuery.of(context).size.width / 8,
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Température minimale / maximale prévue  ${data.main!.tempMin}°C / ${data.main!.tempMax}°C',
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pression ${data.main!.pressure} HPA',
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
