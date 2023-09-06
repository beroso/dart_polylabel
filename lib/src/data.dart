import 'dart:math' show min, sqrt, sqrt2, Point;

typedef Polygon = List<List<Point<double>>>;

class PolylabelResult {
  final Point<double> point;
  final double distance;

  const PolylabelResult(this.point, this.distance);

  @override
  String toString() => 'PolylabelResult($point, distance: $distance)';
}

class Cell {
  // Cell center (x, y).
  final double x;
  final double y;

  final double h; // half the cell size
  final double d; // distance from cell center to polygon

  late final double max;

  Cell(this.x, this.y, this.h, Polygon polygon)
      : d = pointToPolygonDist(x, y, polygon) {
    max = d + h * sqrt2; // max distance to polygon within a cell
  }
}

/// Signed distance from point to polygon outline (negative if point is outside)
double pointToPolygonDist(final double x, final double y, Polygon polygon) {
  bool inside = false;
  double minDistSq = double.infinity;

  for (int k = 0; k < polygon.length; k++) {
    final ring = polygon[k];
    final len = ring.length;

    for (int i = 0, j = len - 1; i < len; j = i++) {
      final a = ring[i];
      final b = ring[j];

      if ((a.y > y != b.y > y) &&
          (x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x)) {
        inside = !inside;
      }

      minDistSq = min<double>(minDistSq, getSegDistSq(x, y, a, b));
    }
  }

  return minDistSq == 0 ? 0 : (inside ? 1 : -1) * sqrt(minDistSq);
}

/// Get squared distance from a point to a segment
double getSegDistSq(
  final double px,
  final double py,
  Point<double> a,
  Point<double> b,
) {
  double x = a.x;
  double y = a.y;
  double dx = b.x - x;
  double dy = b.y - y;

  if (dx != 0 || dy != 0) {
    final t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = b.x;
      y = b.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = px - x;
  dy = py - y;

  return dx * dx + dy * dy;
}
