import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedCitiesPage extends StatefulWidget {
  const SavedCitiesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SavedCitiesPageState createState() => _SavedCitiesPageState();
}

class _SavedCitiesPageState extends State<SavedCitiesPage> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late Future<List<String>> _savedCitiesFuture;
 

  @override
  void initState() {
    super.initState();
    _savedCitiesFuture = _loadSavedCities();
  }

  Future<void> _refreshSavedCities() async {
    setState(() {
      _savedCitiesFuture = _loadSavedCities();
    });
  }

  Future<List<String>> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCities = prefs.getStringList('saved_cities');
    return savedCities ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
         const BoxDecoration(
          gradient: LinearGradient(
            tileMode: TileMode.clamp,
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 100, 169, 179),
              Color.fromARGB(255, 43, 45, 153),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('Villes sauvegardées'),
              backgroundColor:
                  Colors.transparent, // Pour rendre l'appbar transparent
              elevation: 0, // Pour supprimer l'ombre de l'appbar
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSavedCities,
                child: FutureBuilder<List<String>>(
                  future: _savedCitiesFuture,
                  builder: (context, snapshot) {
                    final savedCities = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (savedCities == null || savedCities.isEmpty) {
                      return const Text('Aucune ville sauvegardée');
                    } else {
                      return ListView.builder(
                        itemCount: savedCities.length,
                        itemBuilder: (context, index) {
                          final city = savedCities[index];

                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  city,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _deleteCity(city);
                                  },
                                ),
                              ),
                              const Divider(color: Colors.white),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // fonction pour sauvegarder la ville séléctionner dans shared

  // Future<void> _saveSelectedCity(String city) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('selected_city', city);
  //   _refreshSavedCities(); // Rafraîchir la liste après la sélection
  // }

  // // Récupérer la ville sélectionnée à partir de SharedPreferences
  // Future<void> _getSelectedCity() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _selectedCity = prefs.getString('selected_city') ?? '';
  //   });
  // }

  // suppression des villes
  Future<void> _deleteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCities = prefs.getStringList('saved_cities');

    if (savedCities != null && savedCities.contains(city)) {
      savedCities.remove(city);
      await prefs.setStringList('saved_cities', savedCities);
      _refreshSavedCities(); // Rafraîchir la liste après suppression
    }
  }
}
