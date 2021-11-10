import 'dart:math';

import 'package:polylabel/polylabel.dart';

void main() {
  final polygon = [
    [Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1), Point(0, 0)]
  ];
  final result = polylabel(polygon);
  // PolylabelResult{x: 0.5, y: 0.5, distance: 0.5}
}
