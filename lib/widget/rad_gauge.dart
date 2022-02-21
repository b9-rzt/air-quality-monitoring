import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Widget getRadialGauge(var co2Value) {
  return SfRadialGauge(
      enableLoadingAnimation: true,
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
              endValue: 1500,
              color: Colors.orange,
              startWidth: 10,
              endWidth: 10),
          GaugeRange(
              startValue: 1500,
              endValue: 3000,
              color: Colors.red,
              startWidth: 10,
              endWidth: 10)
        ], pointers: <GaugePointer>[
          NeedlePointer(value: co2Value.toDouble())
        ], annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              // ignore: avoid_unnecessary_containers
              widget: Container(
                  child: Text(co2Value.toString() + ' ppm',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))),
              angle: 90,
              positionFactor: 0.5)
        ])
      ]);
}
