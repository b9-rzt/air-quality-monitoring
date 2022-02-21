import 'package:flutter/material.dart';

// ignore: unused_element
Future<void> showMyDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Fehler'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                  'Es konnte keine Verbindung zu Thingsboard hergestellt werden!'),
              Text(
                  'Überprüfen Sie ob sie sich in dem selben Netzwerk befinden und ob die Einstellungen stimmen.'),
            ],
          ),
        ),
        actions: <Widget>[
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
