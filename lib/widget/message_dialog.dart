import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

/// error dialog
Future<void> showMessageDialog(
    BuildContext context, int value, VoidCallback buttonpress) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Co2 Alarm'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Der Co2-Wert liegt ${value >= 2000 ? "über 2000 und ist somit Hygienisch inakzeptabel!" : "im Bereich zwischen 1000 und 2000 und ist somit Hygienisch bedenklich!"}'),
              Text(value >= 2000
                  ? 'Aus diesem Grund sollte umgehend gelüftet werden um die Belastung zu senken!'
                  : 'Aus diesem Grund sollte gelüftet werden!'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              buttonpress();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
