import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';

class StorageAdapter {
  final _storage = const FlutterSecureStorage();
  final _accountNameController =
      TextEditingController(text: 'flutter_secure_storage_service');

  List<_SecItem> _items = [];
  final List<_SecItem> _defaultsettings = [];

  Future<bool> readAll() async {
    debugPrint("StorageAdapter init!");
    _items = [];
    _initDefaultSettings();
    for (int i = 0; i < _defaultsettings.length; i++) {
      _SecItem? e = await readFromSecureStorage(_defaultsettings[i].key);
      while (e == null) {
        writeToSecureStorage(_defaultsettings[i]);
        debugPrint("Write to Storage");
        e = await readFromSecureStorage(_defaultsettings[i].key);
      }
      _items.add(_SecItem(e.key, e.value));
    }
    debugPrint("StorageAdapter init ended!");
    return true;
  }

  // void printall() {
  //   for (int i = 0; i < _items.length; i++) {
  //     debugPrint("Key: ${_items[i].key}");
  //     debugPrint("Key: ${_items[i].value}");
  //   }
  // }

  String getElementwithkey(String key) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].key == key) {
        return _items[i].value;
      }
    }
    return "";
  }

  void _initDefaultSettings() {
    _defaultsettings.add(_SecItem("IPAddress", "192.168.2.117"));
    _defaultsettings.add(_SecItem("Username", "zimmer1@thingsboard.org"));
    _defaultsettings.add(_SecItem("Password", "zimmer1"));
  }

  IOSOptions _getIOSOptions() => IOSOptions(
        accountName: _getAccountName(),
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  String? _getAccountName() =>
      _accountNameController.text.isEmpty ? null : _accountNameController.text;

  Future<void> writeToSecureStorage(_SecItem secitem) async {
    await _storage.write(
        key: secitem.key,
        value: secitem.value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
  }

  Future<_SecItem?> readFromSecureStorage(String key) async {
    String? secret = await _storage.read(
        key: key, iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
    if (secret == null) {
      debugPrint("readfromSecureStorage: secret = $secret");
      secret = "";
      return null;
    } else {
      return _SecItem(key, secret.toString());
    }
  }

  //  void _addNewItem(String key, String value) async {

  //   await _storage.write(
  //       key: key,
  //       value: value,
  //       iOptions: _getIOSOptions(),
  //       aOptions: _getAndroidOptions());
  //   _readAll();
  // }

  // IOSOptions _getIOSOptions() => IOSOptions(
  //       accountName: _getAccountName(),
  //     );

  // AndroidOptions _getAndroidOptions() => const AndroidOptions(
  //       encryptedSharedPreferences: true,
  //     );
}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
