import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theweather/icons/icons.dart';
import 'package:theweather/models/fore_cast_result.dart';
import 'package:theweather/models/location.dart';
import 'package:theweather/models/next_days.dart';
import 'package:theweather/models/weather_result.dart';
import 'package:theweather/network/open_weather_map.dart';
import 'package:theweather/widgets/daily_data.dart';
import 'package:theweather/widgets/fore_cast_tile.dart';
import 'package:theweather/widgets/list_city.dart';
import 'package:theweather/widgets/side_menu_page.dart';
import 'package:theweather/widgets/weather_tile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Nextdays myNextDaysData = Nextdays(list: []);
  final _cityController = TextEditingController();
  String _selectedCity = '';
  OpenWeatherMapByCity weatherMapByCity = OpenWeatherMapByCity();
  bool _isBlackMode = false;
  bool _isCelsius = false;

  int celsiusToFahrenheit(int celsius) {
    return (celsius * 9 ~/ 5) + 32;
  }

  // fonction pour sauvegarder et récupération des villes
  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCities = prefs.getStringList('saved_cities');

    savedCities ??= [];

    if (!savedCities.contains(city)) {
      savedCities.add(city);
      await prefs.setStringList('saved_cities', savedCities);
    }
  }

  Future<WeatherResult> _getWeatherData() async {
    if (_selectedCity.isEmpty) {
      // Pas de recherche de ville, donc utilise les coordonnées actuelles
      final WeatherResult weatherData =
          await OpenWeatherMap().getWeather(controller.locationData.value);
      controller.updateWeatherData(weatherData);
      return weatherData;
    } else {
      // Recherche de ville effectuée, utilise OpenWeatherMapByCity pour récupérer les données météo de la ville recherchée
      final WeatherResult weatherData =
          await OpenWeatherMapByCity().getWeatherByCity(_selectedCity);
      controller.updateWeatherData(weatherData);
      return weatherData;
    }
  }

  Future<void> getWeatherByCity(String city) async {
    WeatherResult weatherData =
        await OpenWeatherMapByCity().getWeatherByCity(city);
    setState(() {
      _selectedCity = city; // Mettre à jour la ville sélectionnée
      controller.updateWeatherData(weatherData);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await enableLocationListener();
      _selectedCity = '';
      _refreshData(); // Appel _refreshData() pour récupérer les données dès le lancement
    });
  }

  Future<void> _refreshData() async {
    // _selectedCity = '';
    controller.locationData.value = await location.getLocation();
    await _getWeatherData();
    if (_cityController.text.isEmpty) {
      _getWeatherData();
    }
    setState(
        () {}); // Met à jour l'interface utilisateur avec les nouvelles données
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  //add new page
  void _newPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedCitiesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: _isBlackMode
            ? Colors.black
            : const Color.fromARGB(255, 100, 169, 179)));
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: Obx(() {
            final WeatherResult? weatherData = controller.weatherResult;
            final decoration = _isBlackMode
                ? const BoxDecoration(color: Colors.black)
                : const BoxDecoration(
                    gradient: LinearGradient(
                      tileMode: TileMode.clamp,
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 100, 169, 179),
                        Color.fromARGB(255, 43, 45, 153)
                      ],
                    ),
                  );
            return Container(
              decoration: decoration,
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    title: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une ville',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) async {
                        if (value.isEmpty) {
                          // Si le champ de recherche est vide, mettez à jour _selectedCity à une chaîne vide
                          setState(() {
                            _selectedCity = '';
                          });
                          await _getWeatherData();
                        } else {
                          // Sinon, recherchez la ville
                          getWeatherByCity(value);
                          _saveCity(
                              value); // Sauvegarder la ville dans "SharedPreferences"
                        }
                        await _getWeatherData();
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          _newPage(context);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: controller.locationData.value.latitude != null
                        ? FutureBuilder<WeatherResult>(
                            future: _getWeatherData(),
                            builder: (context, snapshot) {
                              final data = snapshot.data;
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                              } else if (data == null) {
                                return const Center(
                                  child: Text('Pas de données',
                                      style: TextStyle(color: Colors.white)),
                                );
                              } else {
                                WeatherResult data = snapshot.data!;
                                controller.updateWeatherData(data);
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              35,
                                    ),
                                    if (weatherData != null)
                                      WeatherTile(
                                        context: context,
                                        convert: (value) => _isCelsius
                                            ? value
                                            : celsiusToFahrenheit(value),
                                        data: weatherData,
                                        titleFontSize: 30.0,
                                        subTitle:
                                            DateFormat('dd-MMM-yyyy').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              (data.dt ?? 0) * 1000),
                                        ),
                                        isCelsius: _isCelsius,
                                      ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      height: 130,
                                      child: FutureBuilder(
                                        future: OpenWeatherMapForcast()
                                            .getForecast(
                                                controller.locationData.value),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                snapshot.error.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          } else if (!snapshot.hasData) {
                                            return const Center(
                                              child: Text(
                                                'Pas de données',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ForecastResult data =
                                                snapshot.data as ForecastResult;
                                            final subData =
                                                data.list!.sublist(0, 8);

                                            return ListView.builder(
                                              itemCount: subData.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                final item = subData[index];
                                                return ForeCastTile(
                                                  imageUrl: buildIcon(
                                                      item.weather![0].icon ??
                                                          '',
                                                      isBigSize: false),
                                                  temp: '${item.main!.temp}°C',
                                                  time: DateFormat('HH:mm')
                                                      .format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            (item.dt ?? 0) *
                                                                1000),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: DailyDataForecast(
                                        nextDaysData: myNextDaysData,
                                        isCelsius: _isCelsius,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          )
                        : const Center(
                            child: Text(
                              'Chargement...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      drawer: SideMenuPage(
        onToggleBlack: (value) {
          setState(() {
            _isBlackMode = value;
          });
        },
        onToggleCelsius: (value) {
          setState(() {
            _isCelsius = value;
          });
        },
        isBlackMode: _isBlackMode,
        isCelsius: _isCelsius,
      ),
    );
  }
}