// import 'dart:html';

import 'package:flutter/material.dart';
// import 'package:myapp/Backend/storage_adapter.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:myapp/value/settvalue.dart';
import 'package:regexed_validator/regexed_validator.dart';

// class MySett extends StatelessWidget {
//   MySett({Key? key}) : super(key: key);
//   StorageAdapter sa = StorageAdapter();
//   final ThingsboardAdapterClient _c = ThingsboardAdapterClient();
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Settings(_c),
//     );
//   }
// }

class Settings extends StatefulWidget {
  final ThingsboardAdapterClient _c;
  const Settings(this._c, {Key? key}) : super(key: key);

  // @override
  // SettingsState createState() => SettingsState();
  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _SettingsState(_c);
}

class _SettingsState extends State<Settings> {
  final ThingsboardAdapterClient _c;
  _SettingsState(this._c);

  // // ignore: non_constant_identifier_names
  // final SettValue _selected_notification_value = SettValue(2);
  List<Setting> sett = [];
  Icon check = const Icon(Icons.check, color: Colors.blue);
  Icon close = const Icon(Icons.close, color: Colors.red);

  @override
  void initState() {
    addSettings();

    // debugPrint(c.test);
    super.initState();
  }

  void addSettings() {
    // IP Address
    sett.add(
        Setting(const Icon(Icons.circle_outlined), "IP-Adresse von Thingsboard",
            (String v) {
      if (validator.ip(v)) {
        setState(() {
          sett[0].icon = check;
          // sett[0].changed = true;
          sett[0].saveSetting();
          sett[0].helpertext = "";
        });
      } else {
        setState(() {
          sett[0].icon = close;
          sett[0].helpertext = "Ivalid IP Address!";
        });
      }
    }, "", _c.sa.getElementwithkey("IPAddress"), 16));

    sett.add(Setting(check, "Username:", (String v) {
      sett[1].saveSetting();
    }, "", _c.sa.getElementwithkey("Username"), 40));

    sett.add(Setting.password(check, "Password:", (String v) {
      sett[2].saveSetting();
    }, "", _c.sa.getElementwithkey("Password"), 40));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: const Color.fromRGBO(50, 75, 225, 1),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              for (int count
                  in List.generate(sett.length, (index) => index + 1))
                TextformfieldSettings(context, sett[count - 1]),
            ],
          ),
        ));
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

  // ignore: non_constant_identifier_names
  Widget TextformfieldSettings(BuildContext context, Setting set) {
    return ListTile(
        title: TextFormField(
            obscureText: set.obscure,
            cursorColor: const Color.fromARGB(255, 0, 4, 255),
            initialValue: set.valuetext,
            maxLength: set.maxlength,
            onChanged: set.changefunction,
            decoration: inputdeco(set)));
  }

  InputDecoration inputdeco(Setting set) {
    return InputDecoration(
      labelText: set.settingstext,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      suffixIcon: set.icon,
      helperText: set.helpertext,
      helperStyle: const TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
    );
  }

  // Widget TextfieldSettings(BuildContext context, Setting set) {
  //   return ListTile(
  //       title: TextField(
  //           cursorColor: const Color.fromARGB(255, 0, 4, 255),
  //           obscureText: set.obscure,
  //           // initialValue: set.valuetext,
  //           controller: set.valuetext,
  //           maxLength: set.maxlength,
  //           onChanged: set.changefunction,
  //           decoration: InputDeco(set)));
  // }
}
