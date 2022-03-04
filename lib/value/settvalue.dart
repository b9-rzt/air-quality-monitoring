import 'package:flutter/material.dart';

class SettValue {
  int? value;

  SettValue(this.value);
}

class Setting {
  Icon icon;
  String settingstext;
  Function(String) changefunction;
  String helpertext;
  String valuetext;
  int maxlength;
  // bool changed = false;
  bool obscure = false;

  Setting(this.icon, this.settingstext, this.changefunction, this.helpertext,
      this.valuetext, this.maxlength);

  Setting.password(this.icon, this.settingstext, this.changefunction,
      this.helpertext, this.valuetext, this.maxlength)
      : obscure = true;

  void saveSetting() {
    debugPrint("Saved: $settingstext!");
  }
}
