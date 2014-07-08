import 'dart:io';

class Point {
  num x, y;
  Point(this.x, this.y);
  String toString() => '($x $y)';
}

class Edge {
  Point p1, p2;
  Edge(this.p1, this.p2);
  String toString() => '[$p1 $p2]';
}

class Triangle {
  Point p1, p2, p3;
  Triangle(this.p1, this.p2, this.p3);
  String toString() => '<$p1 $p2 $p3>';
}

class Polygon {
  List<Edge> edges;
  List<Point> vertices;
  Polygon() {
    edges = new List<Edge>();
    vertices = new List<Point>();
  }
  double area() {
    var sum = 0;
    for (var i=0; i<vertices.length; i++) {
      var p1 = vertices[i],
          p2 = vertices[(i + 1) % vertices.length];
      sum += p1.x * p2.y - p2.x * p1.y;
    }
    return (sum/2).abs();
  }
  List<Triangle> triangles() {
    var list = new List<Triangle>();
    Point p1 = vertices.first;
    for (int i = 2; i < vertices.length; i++) {
      Point p2 = vertices[i-1];
      Point p3 = vertices[i];
      list.add(new Triangle(p1, p2, p3));
      print('Triangle: ${list.last}');
    }
    return list;
  }
  bool pointInside(Point p) {
    for (var t in this.triangles()) {
      num area = 1/2*(-t.p2.y*t.p3.x + t.p1.y*(-t.p2.x + t.p3.x) + 
                      t.p1.x*(t.p2.y - t.p3.y) + t.p2.x*t.p3.y).abs();
      num s = 1/(2*area)*(t.p1.y*t.p3.x - t.p1.x*t.p3.y + 
                          (t.p3.y - t.p1.y)*p.x + (t.p1.x - t.p3.x)*p.y);
      num tt = 1/(2*area)*(t.p1.x*t.p2.y - t.p1.y*t.p2.x + 
                          (t.p1.y - t.p2.y)*p.x + (t.p2.x - t.p1.x)*p.y);
      print('$s, $tt, ${1 - s - tt}');
      if (s < 0 && tt < 0 && (1 - s - tt < 0)) {
        return true;
      }
    }
    return false;
  }
}

Polygon union(Polygon p1, Polygon p2) {
  var current;
  var other;
  var index;
  var sorted = new List<Point>()
      ..addAll(p1.vertices)
      ..addAll(p2.vertices)
      ..sort((var p1, var p2) => p1.x - p2.x);
  var p = sorted.first;
  if (p1.vertices.contains(p)) {
    index = p1.vertices.indexOf(p);
    current = p1;
    other = p2;
  } else {
    index = p2.vertices.indexOf(p);
    current = p2;
    other = p1;
  }
  var startPoint = p;
  var result = new Polygon();
  do {
    result.vertices.add(p);
  } while (p != startPoint);
  return null;
}

bool ccw(Point a, Point b, Point c)
  => (c.y-a.y)*(b.x-a.x) > (b.y-a.y)*(c.x-a.x);
  
Point intersect(Edge e1, Edge e2) {
  double a1, a2, b1, b2, c1, c2;
  double r1, r2 , r3, r4;
  double denom, offset, num;
  double x1 = e1.p1.x;
  double y1 = e1.p1.y;
  double x2 = e1.p2.x;
  double y2 = e1.p2.y;
  double x3 = e2.p1.x;
  double y3 = e2.p1.y;
  double x4 = e2.p2.x;
  double y4 = e2.p2.y;
  a1 = y2 - y1;
  b1 = x1 - x2;
  c1 = (x2 * y1) - (x1 * y2);

  r3 = ((a1 * x3) + (b1 * y3) + c1);
  r4 = ((a1 * x4) + (b1 * y4) + c1);
  
  if ((r3 != 0) && (r4 != 0) && sameSign(r3, r4)){
    return null;
  }
  
  // Compute a2, b2, c2
   a2 = y4 - y3;
   b2 = x3 - x4;
   c2 = (x4 * y3) - (x3 * y4);

   // Compute r1 and r2
   r1 = (a2 * x1) + (b2 * y1) + c2;
   r2 = (a2 * x2) + (b2 * y2) + c2;

   // Check signs of r1 and r2. If both point 1 and point 2 lie
   // on same side of second line segment, the line segments do
   // not intersect.
   if ((r1 != 0) && (r2 != 0) && (sameSign(r1, r2))){
     return null;
   }

   //Line segments intersect: compute intersection point.
   denom = (a1 * b2) - (a2 * b1);

   if (denom == 0) {
     return null; //colinear
   }

   if (denom < 0){ 
     offset = -denom / 2; 
   } 
   else {
     offset = denom / 2 ;
   }

   // The denom/2 is to get rounding instead of truncating. It
   // is added or subtracted to the numerator, depending upon the
   // sign of the numerator.
   num = (b1 * c2) - (b2 * c1);
   double x, y;
   if (num < 0){
     x = (num - offset) / denom;
   } 
   else {
     x = (num + offset) / denom;
   }

   num = (a2 * c1) - (a1 * c2);
   if (num < 0){
     y = ( num - offset) / denom;
   } 
   else {
     y = (num + offset) / denom;
   }

   // lines_intersect
   return new Point(x, y);
}

bool sameSign(double a, double b){
  return (( a * b) >= 0);
}

void main(List<String> args) {
  var v = new File(args.first).readAsLinesSync()
      .map((l) => l.trim().split(',').map((n) => num.parse(n)).toList())
      .toList();
  var lengths = v.removeAt(0);
  var i = 0;
  var polygons = new List<Polygon>();
  for (var length in lengths) {
    var polygon = new Polygon();
    while (polygon.edges.length < length) {
      var p1 = new Point(v[i].first, v[i].last);
      i++;
      var p2;
      if (polygon.edges.length == length - 1) {
        p2 = polygon.edges.first.p1;
      } else {
        p2 = new Point(v[i].first, v[i].last);
      }
      var edge = new Edge(p1, p2);
      polygon.edges.add(edge);
      polygon.vertices.add(p1);
    }
    print(polygon.area());
    polygon.triangles();
    print(polygon.pointInside(new Point(2,3)));
    polygons.add(polygon);
  }
  Edge e1 = new Edge(new Point(1,1), new Point(2,2));
  if (polygons.length > 1) {
    union(polygons[0], polygons[1]);
  }
}

