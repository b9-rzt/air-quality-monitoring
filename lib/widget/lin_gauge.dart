import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Widget getLinearGauge(int value, String title) {
  return Container(
    child: Column(children: [
      SfLinearGauge(
        minimum: 0.0,
        maximum: 100.0,
        orientation: LinearGaugeOrientation.vertical,
        majorTickStyle: const LinearTickStyle(length: 20),
        axisLabelStyle: const TextStyle(fontSize: 12.0, color: Colors.black),
        axisTrackStyle: const LinearAxisTrackStyle(
            color: Colors.grey,
            edgeStyle: LinearEdgeStyle.bothFlat,
            thickness: 15.0,
            borderColor: Colors.grey),
        markerPointers: [
          LinearShapePointer(
            value: value.toDouble(),
            color: Colors.orange,
          )
        ],
        barPointers: [
          LinearBarPointer(
            value: value.toDouble(),
            color: Colors.orange,
          )
        ],
      ),
      Text(title,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
    ]),
    margin: const EdgeInsets.all(10),
  );
}
