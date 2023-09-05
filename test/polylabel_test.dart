import 'dart:convert';
import 'dart:math';

import 'package:polylabel/polylabel.dart';
import 'package:test/test.dart';

import 'fixtures/fixture_reader.dart';

List<List<Point<double>>> toPolygon(List original) {
  return original
      .map((polygon) => (polygon as List)
          .map((p) =>
              Point((p.first as num).toDouble(), (p.last as num).toDouble()))
          .toList())
      .toList();
}

List<List<Point<double>>> loadData(String fixtureFile) {
  return toPolygon(jsonDecode(fixture(fixtureFile)));
}

void main() {
  group('polylabel', () {
    final water1 = loadData('water1.json');
    final water2 = loadData('water2.json');

    test('finds pole of inaccessibility for water1 and precision 1', () {
      final watch = Stopwatch()..start();

      const N = 50;
      for (int i = 0; i < N; ++i) {
        final p = polylabel(water1, precision: 1);
        expect(p.point, Point(3865.85009765625, 2124.87841796875));
        expect(p.distance, 288.8493574779127);
      }

      print('Elapsed time for $N iterations of water1: ${watch.elapsed}');
    });

    test('finds pole of inaccessibility for water1 and precision 50', () {
      final p = polylabel(water1, precision: 50);
      expect(p.point, Point(3854.296875, 2123.828125));
      expect(p.distance, 278.5795872381558);
    });

    test(
      'finds pole of inaccessibility for water2 and default precision 1',
      () {
        final p = polylabel(water2);
        expect(p.point, Point(3263.5, 3263.5));
        expect(p.distance, 960.5);
      },
    );

    test('works on degenerate polygons', () {
      final p1 = polylabel(toPolygon([
        [
          [0, 0],
          [1, 0],
          [2, 0],
          [0, 0]
        ]
      ]));
      expect(p1.point, Point(0, 0));
      expect(p1.distance, 0);

      final p2 = polylabel(toPolygon([
        [
          [0, 0],
          [1, 0],
          [1, 1],
          [1, 0],
          [0, 0]
        ]
      ]));
      expect(p2.point, Point(0, 0));
      expect(p2.distance, 0);
    });
  });
}
