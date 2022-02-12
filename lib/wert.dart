class Wert {
  late int _ts;
  late int _value;
  late String _key;

  Wert(this._ts, this._value, this._key);

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
