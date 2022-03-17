import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:myapp/value/settvalue.dart';
import 'package:regexed_validator/regexed_validator.dart';

/// Settings Page
class Settings extends StatefulWidget {
  final ThingsboardAdapterClient _c;
  const Settings(this._c, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _SettingsState(_c);
}

class _SettingsState extends State<Settings> {
  final ThingsboardAdapterClient _c;
  _SettingsState(this._c);

  /// list with settings
  List<Setting> sett = [];

  /// definition of the most used icons
  Icon check = const Icon(Icons.check, color: Colors.blue);
  Icon close = const Icon(Icons.close, color: Colors.red);

  @override
  void initState() {
    addSettings();
    super.initState();
  }

  /// initiate the settings
  void addSettings() {
    /// setting ip address
    sett.add(Setting("IPAddress", const Icon(Icons.circle_outlined),
        "IP-Adresse von Thingsboard", (String v) {
      if (validator.ip(v)) {
        setState(() {
          sett[0].icon = check;
          sett[0].valuetext = v;
          sett[0].saveSetting(_c);
          sett[0].helpertext = "";
        });
      } else {
        setState(() {
          sett[0].icon = close;
          sett[0].helpertext = "Ivalid IP Address!";
        });
      }
    }, "", _c.sa.getElementwithkey("IPAddress"), 16));

    /// setting username
    sett.add(Setting("Username", check, "Username:", (String v) {
      setState(() {
        sett[1].valuetext = v;
        sett[1].saveSetting(_c);
      });
    }, "", _c.sa.getElementwithkey("Username"), 40));

    /// setting password
    sett.add(Setting.password("Password", check, "Password:", (String v) {
      setState(() {
        sett[2].valuetext = v;
        sett[2].saveSetting(_c);
      });
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

              /// list the settings on the page
              for (int count
                  in List.generate(sett.length, (index) => index + 1))
                textformfieldSettings(context, sett[count - 1]),
            ],
          ),
        ));
  }

  /// label widget
  Widget label(String text) {
    return Text(
      text,
      style:
          Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black),
    );
  }

  /// divider widget
  Widget div() {
    return const Divider(
      color: Colors.black,
      height: 5,
    );
  }

  /// radio button widget for the future
  // Widget radioText(
  //     BuildContext context, String text, SettValue groupvalue, int value1) {
  //   return ListTile(
  //     title: Text(
  //       text,
  //       style: Theme.of(context)
  //           .textTheme
  //           .subtitle1!
  //           .copyWith(color: Colors.black),
  //     ),
  //     trailing: Radio(
  //       value: value1,
  //       groupValue: groupvalue.value,
  //       activeColor: const Color.fromARGB(255, 4, 0, 238),
  //       onChanged: (int? value) {
  //         setState(() {
  //           groupvalue.value = value;
  //         });
  //       },
  //     ),
  //   );
  // }

  /// textfield for editing the settings
  Widget textformfieldSettings(BuildContext context, Setting set) {
    return ListTile(
        title: TextFormField(
            obscureText: set.obscure,
            cursorColor: const Color.fromARGB(255, 0, 4, 255),
            initialValue: set.valuetext,
            maxLength: set.maxlength,
            onChanged: set.changefunction,
            decoration: inputdeco(set)));
  }

  /// decoration of the textfields
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
}
