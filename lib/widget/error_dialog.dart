import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:myapp/pages/settings.dart';

/// error dialog
// ignore: unused_element
Future<void> showMyDialog(BuildContext context, ThingsboardAdapterClient _c) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Fehler'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Es konnte keine Verbindung zu Thingsboard hergestellt werden! ${_c.sa.getElementwithkey("IPAddress")}'),
              const Text(
                  'Überprüfen Sie ob sie sich in dem selben Netzwerk befinden und ob die Einstellungen stimmen.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Einstellungen'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Settings(_c)));
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
