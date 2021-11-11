import 'dart:math' show min, sqrt, sqrt2, Point;

typedef Polygon = List<List<Point>>;

class PolylabelResult {
  final num x;
  final num y;
  final num distance;
  PolylabelResult(this.x, this.y, this.distance);
}

class Cell {
  final Point c; // cell center
  final num h; // half the cell size
  final num d; // distance from cell center to polygon
  late num max; // max distance to polygon within a cell

  Cell(this.c, this.h, Polygon polygon) : d = pointToPolygonDist(c, polygon) {
    max = d + h * sqrt2;
  }
}

/// Signed distance from point to polygon outline (negative if point is outside)
num pointToPolygonDist(Point point, Polygon polygon) {
  bool inside = false;
  num minDistSq = double.infinity;

  for (var k = 0; k < polygon.length; k++) {
    final ring = polygon[k];

    for (var i = 0, len = ring.length, j = len - 1; i < len; j = i++) {
      final a = ring[i];
      final b = ring[j];

      if ((a.y > point.y != b.y > point.y) &&
          (point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x)) {
        inside = !inside;
      }

      minDistSq = min(minDistSq, getSegDistSq(point, a, b));
    }
  }

  return minDistSq == 0 ? 0 : (inside ? 1 : -1) * sqrt(minDistSq);
}

/// Get squared distance from a point to a segment
num getSegDistSq(Point p, Point a, Point b) {
  num x = a.x;
  num y = a.y;
  num dx = b.x - x;
  num dy = b.y - y;

  if (dx != 0 || dy != 0) {
    final t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = b.x;
      y = b.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;

  return dx * dx + dy * dy;
}
