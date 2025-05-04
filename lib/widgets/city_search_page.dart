import 'package:flutter/material.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CitySearchPageState createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController searchController = TextEditingController();

  void _onCitySelected(BuildContext context) {
    // Get the selected city from the search controller.
    String selectedCity = searchController.text;
    // Pass the selected city back to the previous page (MyHomePage).
    Navigator.pop(context, selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Rechercher une ville",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      body: const Center(
        // Implement the city search UI here, e.g., a ListView of search results.
        child: Text('City Search Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCitySelected(context),
        child: const Icon(Icons.search),
      ),
    );
  }
}
