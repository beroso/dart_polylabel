import 'dart:math';

import 'package:polylabel/polylabel.dart';

void main() {
  final polygon = [
    [
      Point<double>(0, 0),
      Point<double>(1, 0),
      Point<double>(1, 1),
      Point<double>(0, 1),
      Point<double>(0, 0)
    ]
  ];
  final result = polylabel(polygon);
  print(result); // PolylabelResult(Point(0.5, 0.5), distance: 0.5)
}
