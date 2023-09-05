import 'dart:math' show min, Point;
import 'package:collection/collection.dart';

import 'data.dart';

/// Finds the polygon pole of inaccessibility.
///
/// Precision is given in "polygon point" units. Generally, a larger number
/// means a looser acceptance threshold and thus a lower precision.
PolylabelResult polylabel(
  Polygon polygon, {
  double precision = 1.0,
  bool debug = false,
}) {
  if (polygon.isEmpty || polygon[0].isEmpty) {
    return _empty;
  }

  final ring = polygon[0];

  // find the bounding box of the outer ring
  double minX = ring[0].x, minY = ring[0].y, maxX = ring[0].x, maxY = ring[0].y;

  for (int i = 0; i < ring.length; i++) {
    final p = ring[i];

    if (p.x < minX) minX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.x > maxX) maxX = p.x;
    if (p.y > maxY) maxY = p.y;
  }

  final width = maxX - minX;
  final height = maxY - minY;
  final cellSize = min<double>(width, height);
  if (cellSize == 0) {
    return _empty;
  }

  // a priority queue of cells in order of their "potential" (max distance to polygon)
  final cellQueue = PriorityQueue<Cell>((a, b) => b.max.compareTo(a.max));

  // cover polygon with initial cells
  final h = cellSize / 2;
  for (var x = minX; x < maxX; x += cellSize) {
    for (var y = minY; y < maxY; y += cellSize) {
      final dx = x + h;
      final dy = y + h;
      cellQueue.add(Cell(dx, dy, h, polygon));
    }
  }

  // take centroid as the first best guess
  Cell bestCell = _getCentroidCell(polygon);

  // second guess: bounding box centroid
  final bboxCell = Cell(minX + width / 2, minY + height / 2, 0, polygon);
  if (bboxCell.d > bestCell.d) {
    bestCell = bboxCell;
  }

  while (cellQueue.isNotEmpty) {
    // pick the most promising cell from the queue
    final cell = cellQueue.removeFirst();

    // update the best cell if we found a better one (i.e maximizing the distance).
    if (cell.d > bestCell.d) {
      bestCell = cell;
      if (debug) {
        print(
          'found best ${(1e4 * cell.d).round() / 1e4} after ${cellQueue.length} probes',
        );
      }
    }

    // do not drill down further if there's no chance of a better solution
    if (cell.max - bestCell.d <= precision) {
      continue;
    }

    // split the cell into four cells
    final h = cell.h / 2;
    cellQueue.add(Cell(cell.x - h, cell.y - h, h, polygon));
    cellQueue.add(Cell(cell.x + h, cell.y - h, h, polygon));
    cellQueue.add(Cell(cell.x - h, cell.y + h, h, polygon));
    cellQueue.add(Cell(cell.x + h, cell.y + h, h, polygon));
  }

  if (debug) {
    print('best distance: ${bestCell.d}');
  }

  return PolylabelResult(Point<double>(bestCell.x, bestCell.y), bestCell.d);
}

/// Get polygon centroid
Cell _getCentroidCell(Polygon polygon) {
  double area = 0;
  double x = 0;
  double y = 0;
  final ring = polygon[0];
  final len = ring.length;

  for (int i = 0, j = len - 1; i < len; j = i++) {
    final a = ring[i];
    final b = ring[j];
    final f = a.x * b.y - b.x * a.y;
    x += (a.x + b.x) * f;
    y += (a.y + b.y) * f;
    area += f * 3;
  }

  if (area == 0) {
    return Cell(ring[0].x, ring[0].y, 0, polygon);
  }
  return Cell(x / area, y / area, 0, polygon);
}

const _empty = PolylabelResult(Point<double>(0, 0), 0);
