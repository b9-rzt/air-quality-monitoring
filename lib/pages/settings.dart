import 'package:flutter/material.dart';
import 'package:myapp/value/settvalue.dart';

class MySett extends StatelessWidget {
  const MySett({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Settings(),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // ignore: non_constant_identifier_names
  final SettValue _selected_notification_value = SettValue(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromRGBO(50, 75, 225, 1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          label('Notifications'),
          radioText(
              context, "Allow notifications", _selected_notification_value, 1),
          radioText(context, "Turn off notifications",
              _selected_notification_value, 2),
          div(),
        ],
      ),
    );
  }

  Widget label(String text) {
    return Text(
      text,
      style:
          Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black),
    );
  }

  Widget div() {
    return const Divider(
      color: Colors.black,
      height: 5,
    );
  }

  Widget radioText(
      BuildContext context, String text, SettValue groupvalue, int value1) {
    return ListTile(
      title: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: Colors.black),
      ),
      trailing: Radio(
        value: value1,
        groupValue: groupvalue.value,
        activeColor: const Color.fromARGB(255, 4, 0, 238),
        onChanged: (int? value) {
          setState(() {
            groupvalue.value = value;
          });
        },
      ),
    );
  }
}
