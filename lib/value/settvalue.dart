import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';

/// classes for the settings
class SettValue {
  int? value;

  SettValue(this.value);
}

class Setting {
  String key;
  Icon icon;
  String settingstext;
  Function(String) changefunction;
  String helpertext;
  String valuetext;
  int maxlength;
  bool obscure = false;

  Setting(this.key, this.icon, this.settingstext, this.changefunction,
      this.helpertext, this.valuetext, this.maxlength);

  Setting.password(this.key, this.icon, this.settingstext, this.changefunction,
      this.helpertext, this.valuetext, this.maxlength)
      : obscure = true;

  void saveSetting(ThingsboardAdapterClient _c) {
    _c.sa.updateElementwithKey(key, valuetext);

    debugPrint("Saved: $key : $valuetext!");
  }
}
