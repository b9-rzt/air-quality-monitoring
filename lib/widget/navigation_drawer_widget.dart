import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:myapp/pages/settings.dart';

/// Navigation drawer widget
class NavigationDrawerWidget extends StatelessWidget {
  final ThingsboardAdapterClient _c;
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const NavigationDrawerWidget(this._c, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Material(
      color: const Color.fromRGBO(50, 75, 225, 1),
      child: ListView(
        padding: padding,
        reverse: true,
        children: <Widget>[
          const SizedBox(height: 10),
          buildMenuItem(
            text: 'Settings',
            icon: Icons.settings,
            onClicked: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Settings(_c)));
            },
          ),
          const Divider(
            color: Colors.white70,
            height: 5,
          ),
        ],
      ),
    ));
  }

  /// build one item in the navigation drawer
  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }
}
