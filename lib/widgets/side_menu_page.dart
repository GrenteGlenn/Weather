import 'package:flutter/material.dart';

class SideMenuPage extends StatefulWidget {
  final Function(bool) onToggleBlack;
  final Function(bool) onToggleCelsius;
  final bool isBlackMode;
  final bool isCelsius;

  const SideMenuPage(
      {Key? key,
      required this.onToggleBlack,
      required this.isBlackMode,
      required this.onToggleCelsius,
      required this.isCelsius})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SideMenuPageState createState() => _SideMenuPageState();
}

class _SideMenuPageState extends State<SideMenuPage> {

  void onToggleBlack(bool value) {
    setState(() {
    });
    widget.onToggleBlack(value);
  }

  void onToggleCelsius(bool value) {
    setState(() {
    });
    widget.onToggleCelsius(value);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 100, 169, 179),
            ),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mode sombre'),
                Switch(
                  value: widget
                      .isBlackMode, 
                  onChanged: (value) {
                    widget.onToggleBlack(value);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.isCelsius
                    ? 'Fahrenheit'
                    : 'Celsius'),
                Switch(
                  value: widget
                      .isCelsius, 
                  onChanged: (value) {
                    widget.onToggleCelsius(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}