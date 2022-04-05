import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';

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
  bool _hidePassword = true;

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

              Form(
                child: TextFormField(
                  onChanged: (value) {
                    _c.sa.updateElementwithKey("IPAddress", value);
                  },
                  initialValue: _c.sa.getElementwithkey("IPAddress"),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "IP Addresse von Thingsboard",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.dns,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              Form(
                child: TextFormField(
                  onChanged: (value) {
                    _c.sa.updateElementwithKey("Username", value);
                  },
                  initialValue: _c.sa.getElementwithkey("Username"),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Username",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.supervised_user_circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Passwordfield
              Form(
                child: TextFormField(
                  onChanged: (value) {
                    _c.sa.updateElementwithKey("Password", value);
                  },
                  keyboardType: TextInputType.text,
                  obscureText: _hidePassword,
                  initialValue: _c.sa.getElementwithkey("Password"),
                  decoration: InputDecoration(
                    labelText: "Password",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                      icon: Icon(_hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
