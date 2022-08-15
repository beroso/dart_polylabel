<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# polylabel

[![build](https://github.com/beroso/dart_polylabel/actions/workflows/dart.yml/badge.svg)](https://github.com/beroso/dart_polylabel/actions/workflows/dart.yml)
[![pub package](https://img.shields.io/pub/v/polylabel.svg)](https://pub.dev/packages/polylabel)
[![pub points](https://img.shields.io/pub/points/sentry?logo=dart)](https://pub.dev/packages/polylabel/score)
[![popularity](https://img.shields.io/pub/popularity/polylabel?logo=dart)](https://pub.dev/packages/polylabel/score)
[![likes](https://img.shields.io/pub/likes/polylabel?logo=dart)](https://pub.dev/packages/polylabel/score)


Dart port of https://github.com/mapbox/polylabel.

A fast algorithm for finding polygon pole of inaccessibility implemented as a Dart library. Useful for optimal placement of a text label on a polygon.

## Usage

```dart
import 'dart:math';

import 'package:polylabel/polylabel.dart';

final polygon = [[Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1), Point(0, 0)]];
final result = polylabel(polygon); // PolylabelResult(Point(0.5, 0.5), distance: 0.5)
```
