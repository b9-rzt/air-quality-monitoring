import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/Backend/thingsboard_adapter_client.dart';
import 'package:myapp/value/value_classes.dart';
import 'package:myapp/widget/lin_gauge.dart';
import 'package:myapp/widget/navigation_drawer_widget.dart';
import 'package:myapp/widget/rad_gauge.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../widget/message_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, ThingsboardAdapterClient? r})
      : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// Main Home Page
///
/// the page shows the gauges with the sensor values
/// shows also the rooms in a dropdownmenu
class MyHomePageState extends State<MyHomePage> {
  bool warningmessage = false;
  final SettStringValue? _v = SettStringValue(null);
  final ThingsboardAdapterClient _c = ThingsboardAdapterClient();

  /// List for the selectable rooms/ devices
  final Roomlist _list = Roomlist(['Wählen Sie den Raum aus!']);

  /// Subscription
  late StreamSubscription _substream;

  /// displayed values
  var _co2value = 0;
  var _humvalue = 0;
  var _tempvalue = 0;

  /// is the subscribtion started
  bool _substart = false;

  /// List of possible devices
  List? _devices = [[], []];

  /// init function to read all elements from storage before initialisate
  @override
  void initState() {
    _c.setcontext(context);
    _c.sa.readAll().then(
          (value) => start(),
        );
    super.initState();
  }

  /// widgets on the main page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(
          _c,
        ),
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color.fromRGBO(50, 75, 225, 1),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            dropdown(_v, _list),
            const Align(alignment: Alignment.topCenter),
            getRadialGauge(_co2value),
            getLinearGauge(_humvalue, "Humidity: $_humvalue%"),
            const SizedBox(width: 10),
            getLinearGauge(_tempvalue, "Temperature: $_tempvalue°C"),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        )));
  }

  /// login to the websocket
  Future<void> start() async {
    await _c.login();
    _devices = await _c.getDevices();
    if (_devices != null) {
      setState(() {
        _v?.value = 'Wählen Sie den Raum aus!';
        for (var i = 0; i < _devices![0].length; i++) {
          _list.raum.add(_devices![0][i]);
        }
      });
    }
  }

  /// start subscribtion of the sensor values
  Future<void> startsub(String devicename) async {
    if (_substart) {
      await _c.unsubscripe();
      _substream.cancel();
      _c.resetvalues();
    }
    await _c.getdevice(_devices![1][_devices![0].indexOf(devicename)]);
    TelemetrySubscriber? _subscription = await _c.subscripe();
    _substart = true;
    _substream = _subscription.entityDataStream.listen(
        (entityDataUpdate) {
          _c.dataupdate(entityDataUpdate);
          setState(() {
            _co2value = _c.lastCo2.getvalue();
            _humvalue = _c.lastHum.getvalue();
            _tempvalue = _c.lastTemp.getvalue();
          });
          if (_co2value >= 1000 && !warningmessage) {
            warningmessage = true;
            showMessageDialog(context, _co2value, () {
              warningmessage = false;
            });
          }
        },
        onError: (error, t) => debugPrint("An error happend!"),
        onDone: () {
          debugPrint("Data-Stream ended!");
          _substart = false;
        });
    debugPrint("startsub Function after _substream");
  }

  /// widget to can select the rooms in a dropdownmenu
  Widget dropdown(SettStringValue? dropdownValue, Roomlist texts) {
    if (dropdownValue?.value == null) {
      return TextButton(
          onPressed: () {
            start();
          },
          child: const Icon(Icons.replay_outlined));
    }
    return DropdownButton<String>(
      value: dropdownValue?.value,
      icon: const Icon(Icons.keyboard_arrow_down),
      elevation: 16,
      style:
          Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black),
      underline: Container(
        height: 2,
        width: 20,
        color: const Color.fromRGBO(50, 75, 225, 1),
      ),
      onChanged: (String? newValue) {
        setState(() {
          if (_list.raum.contains('Wählen Sie den Raum aus!') &&
              newValue != 'Wählen Sie den Raum aus!') {
            _list.raum.removeAt(_list.raum.indexOf('Wählen Sie den Raum aus!'));
          }
          if (newValue != 'Wählen Sie den Raum aus!' &&
              newValue != dropdownValue?.value) {
            startsub(newValue!);
          }
          dropdownValue?.value = newValue!;
        });
      },
      items: texts.raum.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class SettStringValue {
  String? value;

  SettStringValue(this.value);
}
