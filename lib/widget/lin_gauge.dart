import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// widget linear gauge
///
/// returns a linear gauge as a widget
Widget getLinearGauge(int value, String title, double min, double max,
    List<LinearGaugeRange>? lin) {
  return Container(
    child: Column(children: [
      SfLinearGauge(
        minimum: min,
        maximum: max,
        ranges: lin,
        orientation: LinearGaugeOrientation.horizontal,
        majorTickStyle: const LinearTickStyle(length: 10),
        axisLabelStyle: const TextStyle(fontSize: 12.0, color: Colors.black),
        axisTrackStyle: const LinearAxisTrackStyle(
            color: Colors.grey,
            edgeStyle: LinearEdgeStyle.bothFlat,
            thickness: 0.0,
            borderColor: Colors.grey),
        markerPointers: [
          LinearShapePointer(
            value: value.toDouble(),
            color: Colors.orange,
            elevation: 10,
          )
        ],
        // barPointers: [
        //   LinearBarPointer(
        //     value: value.toDouble(),
        //     color: Color.fromARGB(255, 138, 20, 20),
        //   ),
        // ],
      ),
      Text(title,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
    ]),
    margin: const EdgeInsets.all(10),
  );
}
