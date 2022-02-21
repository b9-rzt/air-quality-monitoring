class Wert {
  late int _ts;
  late int _value;
  late String _key;

  Wert(this._ts, this._value, this._key);

  void resetvalues() {
    _ts = 0;
    _value = 0;
  }

  void setts(int ts) {
    _ts = ts;
  }

  void setvalue(int value) {
    _value = value;
  }

  void setkey(String key) {
    _key = key;
  }

  int getts() {
    return _ts;
  }

  int getvalue() {
    return _value;
  }

  String getkey() {
    return _key;
  }
}

// class StringList {
//   var devices = [[], []];

//   StringList(this.devices);

//   List getdevices() {
//     return devices;
//   }
// }

class Raumliste {
  List<String> raum = [];
  Raumliste(this.raum);
}
