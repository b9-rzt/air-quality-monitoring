import 'package:flutter/material.dart';
import 'package:myapp/client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

// import 'package:testapp/thingsboardclient.dart';
Client c = Client();

void main() {
  // runApp(GaugeApp());
  runApp(const MyApp());
}

Map<int, Color> color = {
  50: const Color.fromRGBO(136, 14, 79, .1),
  100: const Color.fromRGBO(136, 14, 79, .2),
  200: const Color.fromRGBO(136, 14, 79, .3),
  300: const Color.fromRGBO(136, 14, 79, .4),
  400: const Color.fromRGBO(136, 14, 79, .5),
  500: const Color.fromRGBO(136, 14, 79, .6),
  600: const Color.fromRGBO(136, 14, 79, .7),
  700: const Color.fromRGBO(136, 14, 79, .8),
  800: const Color.fromRGBO(136, 14, 79, .9),
  900: const Color.fromRGBO(136, 14, 79, 1),
  //Color.fromARGB(255, 25, 7, 128),
};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Thingsboard',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xFF0000F0, color),
      ),
      home: const MyHomePage(title: 'Thingsboard Values'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: non_constant_identifier_names
  int _co2_value = 0;
  bool _substart = false;

  Future<void> _aktualisation() async {
    setState(() {
      _co2_value = c.LastCo2.getvalue();
      // getdevice();
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  Future<void> logout() async {
    await c.logout();
  }

  Future<void> startsub() async {
    if (_substart) {
      return;
    }
    TelemetrySubscriber _subscription = await c.subscripe();
    _subscription.entityDataStream.listen((entityDataUpdate) {
      c.dataupdate(entityDataUpdate);
      setState(() {
        _co2_value = c.LastCo2.getvalue();
      });
    });

    _substart = true;
  }

  Future<void> stopsub() async {
    await c.unsubscripe();
    await c.logout();
  }

  Widget _getRadialGauge() {
    return SfRadialGauge(
        title: const GaugeTitle(
            text: 'Co2-Value',
            textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 3000, ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 800,
                color: Colors.green,
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 800,
                endValue: 1000,
                color: Colors.orange,
                startWidth: 10,
                endWidth: 10),
            GaugeRange(
                startValue: 1000,
                endValue: 3000,
                color: Colors.red,
                startWidth: 10,
                endWidth: 10)
          ], pointers: <GaugePointer>[
            NeedlePointer(value: _co2_value.toDouble())
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                // ignore: avoid_unnecessary_containers
                widget: Container(
                    child: Text(_co2_value.toString() + ' ppm',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold))),
                angle: 90,
                positionFactor: 0.5)
          ])
        ]);
  }

  @override
  Widget build(BuildContext context) {
    startsub();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getRadialGauge(),
            // Text(
            //   'Co2:',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            // Text(
            //   '$_co2_value',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            // TextButton(onPressed: startsub, child: const Text("Subscribe")),
            // TextButton(onPressed: stopsub, child: const Text("Unsubscribe")),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _aktualisation,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: MaterialColor(0xFF0000F0, color),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
