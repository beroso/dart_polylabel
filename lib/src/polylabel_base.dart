import 'dart:math' show min, sqrt, sqrt2, Point;
import 'package:collection/collection.dart';

typedef Polygon = List<List<Point>>;

class Cell {
  final Point c; // cell center
  final num h; // half the cell size
  final num d; // distance from cell center to polygon
  late num max; // max distance to polygon within a cell

  Cell(this.c, this.h, Polygon polygon) : d = pointToPolygonDist(c, polygon) {
    max = d + h * sqrt2;
  }
}

class PolylabelResult {
  final num x;
  final num y;
  final num distance;
  PolylabelResult(this.x, this.y, this.distance);
}

/// Finds the polygon pole of inaccessibility, the most distant internal point
/// from the polygon outline (not to be confused with centroid).
///
/// Useful for optimal placement of a text label on a polygon.
PolylabelResult polylabel(
  List<List<Point>> polygon, {
  double precision = 1.0,
  bool debug = false,
}) {
  // find the bounding box of the outer ring
  num minX = 0, minY = 0, maxX = 0, maxY = 0;
  for (var i = 0; i < polygon[0].length; i++) {
    var p = polygon[0][i];
    if (i == 0 || p.x < minX) minX = p.x;
    if (i == 0 || p.y < minY) minY = p.y;
    if (i == 0 || p.x > maxX) maxX = p.x;
    if (i == 0 || p.y > maxY) maxY = p.y;
  }

  num width = maxX - minX;
  num height = maxY - minY;
  num cellSize = min(width, height);
  num h = cellSize / 2;

  if (cellSize == 0) {
    return PolylabelResult(minX, minY, 0);
  }

  // a priority queue of cells in order of their "potential" (max distance to polygon)
  final cellQueue = PriorityQueue<Cell>(compareMax);

  // cover polygon with initial cells
  for (var x = minX; x < maxX; x += cellSize) {
    for (var y = minY; y < maxY; y += cellSize) {
      cellQueue.add(Cell(Point(x + h, y + h), h, polygon));
    }
  }

  // take centroid as the first best guess
  var bestCell = getCentroidCell(polygon);

  // second guess: bounding box centroid
  var bboxCell = Cell(Point(minX + width / 2, minY + height / 2), 0, polygon);
  if (bboxCell.d > bestCell.d) bestCell = bboxCell;

  int numProbes = cellQueue.length;

  while (cellQueue.isNotEmpty) {
    // pick the most promising cell from the queue
    final cell = cellQueue.removeFirst();

    // update the best cell if we found a better one
    if (cell.d > bestCell.d) {
      bestCell = cell;
      if (debug) {
        print(
          'found best ${(1e4 * cell.d).round() / 1e4} after $numProbes probes',
        );
      }
    }

    // do not drill down further if there's no chance of a better solution
    if (cell.max - bestCell.d <= precision) continue;

    // split the cell into four cells
    h = cell.h / 2;
    cellQueue.add(Cell(Point(cell.c.x - h, cell.c.y - h), h, polygon));
    cellQueue.add(Cell(Point(cell.c.x + h, cell.c.y - h), h, polygon));
    cellQueue.add(Cell(Point(cell.c.x - h, cell.c.y + h), h, polygon));
    cellQueue.add(Cell(Point(cell.c.x + h, cell.c.y + h), h, polygon));
    numProbes += 4;
  }

  if (debug) {
    print('best distance: ${bestCell.d}');
  }

  return PolylabelResult(bestCell.c.x, bestCell.c.y, bestCell.d);
}

/// Compare two cells
int compareMax(Cell a, Cell b) {
  return (b.max - a.max).toInt();
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

/// Get polygon centroid
Cell getCentroidCell(Polygon polygon) {
  num area = 0;
  num x = 0;
  num y = 0;
  final ring = polygon[0];

  for (var i = 0, len = ring.length, j = len - 1; i < len; j = i++) {
    final a = ring[i];
    final b = ring[j];
    final f = a.x * b.y - b.x * a.y;
    x += (a.x + b.x) * f;
    y += (a.y + b.y) * f;
    area += f * 3;
  }
  if (area == 0) return Cell(ring[0], 0, polygon);
  return Cell(Point(x / area, y / area), 0, polygon);
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
