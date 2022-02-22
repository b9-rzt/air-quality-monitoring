import 'package:flutter/material.dart';
import 'package:myapp/client.dart';
import 'package:myapp/value/settvalue.dart';
import 'package:myapp/value/wert.dart';
import 'package:myapp/widget/lin_gauge.dart';
import 'package:myapp/widget/navigation_drawer_widget.dart';
import 'package:myapp/widget/rad_gauge.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SettStringValue? _v = SettStringValue(null);
  final Raumliste _list = Raumliste(['Wählen Sie den Raum aus!']);

  var _co2value = 0;
  var _humvalue = 0;
  var _tempvalue = 0;
  bool _substart = false;
  Client c = Client();
  List? _devices = [[], []];

  @override
  void initState() {
    c.setcontext(context);
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavigationDrawerWidget(),
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

  Future<void> start() async {
    await c.login();
    _devices = await c.getDevices();
    if (_devices != null) {
      setState(() {
        _v?.value = 'Wählen Sie den Raum aus!';
        for (var i = 0; i < _devices![0].length; i++) {
          _list.raum.add(_devices![0][i]);
        }
      });
    }
  }

  Future<void> startsub(String devicename) async {
    if (_substart) {
      await c.unsubscripe();
      c.resetvalues();
    }
    await c.getdevice(_devices![1][_devices![0].indexOf(devicename)]);
    TelemetrySubscriber? _subscription = await c.subscripe();
    _subscription.entityDataStream.listen((entityDataUpdate) {
      c.dataupdate(entityDataUpdate);
      setState(() {
        _co2value = c.lastCo2.getvalue();
        _humvalue = c.lastHum.getvalue();
        _tempvalue = c.lastTemp.getvalue();
      });
    }, onDone: () {
      _substart = false;
    });

    _substart = true;
  }

  Future<void> stopsub() async {
    await c.unsubscripe();
    await c.logout();
  }

  Widget dropdown(SettStringValue? dropdownValue, Raumliste texts) {
    if (dropdownValue?.value == null) {
      return TextButton(
          onPressed: () {
            start();
          },
          child: const Text('Reload'));
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
