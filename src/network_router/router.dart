import 'dart:io';
import 'dart:collection';

class Edge {
  Node n1;
  Node n2;
  num weight;
  Edge.connect(this.n1, this.n2, this.weight) {
    n1.edges.add(this);
    n2.edges.add(this);
  }
  bool operator ==(other) => (n1 == other.n1 && n2 == other.n2) || (n1 == other.n2 && n2 == other.n1);
  int get hashCode => n1.hashCode + n2.hashCode;
}

class Node {
  Set<Edge> edges = new Set();
  String label;
  bool visited = false;
  num distance = double.MAX_FINITE;
  Node previous = null;

  Node(this.label);
  bool operator ==(other) => label == other.label;
  int get hashCode => label.hashCode;
  List<Node> reachable() {
    var nodes = new Set<Node>();
    edges.forEach((e) {
      nodes.addAll([e.n1, e.n2]);
    });
    nodes.remove(this);
    return nodes.toList();
  }
}

class Graph {

  Set<Edge> edges;
  Set<Node> nodes;

  Graph.fromDistanceMatrix(List<List<num>> m) {
    int h = m.length;
    int w = m[0].length;
    assert(w == h);
    List<String> labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    edges = new Set<Edge>();
    nodes = new Set<Node>();
    for (int i = 0; i < h; i++) {
      for (int j = i + 1; j < w; j++) {
        num w = m[i][j];
        if (w >= 0) {
          Node n1 = getOrAddNode(labels[i]);
          Node n2 = getOrAddNode(labels[j]);
          Edge e = new Edge.connect(n1, n2, w);
          edges.add(e);
        }
      }
    }
  }

  List<Node> shortestRoute(Node s, Node e) {
    nodes.forEach((n) {
      n.visited = false;
      n.distance = double.MAX_FINITE;
      n.previous = null;
    });
    Node start = nodes.lookup(s);
    Node end = nodes.lookup(e);
    start.distance = 0;
    var queue = new SplayTreeMap<Node, Node>((n1, n2) {
      var cmp = n1.distance.compareTo(n2.distance);
      return cmp == 0 ? n1.label.compareTo(n2.label) : cmp;
    });
    nodes.forEach((n) {
      queue[n] = n;
    });

    var current = start;
    while (!end.visited) {
      for (var edge in current.edges) {
        var node = (current == edge.n1 ? edge.n2 : edge.n1);
        if (!node.visited) {
          var d = current.distance + edge.weight;
          if (d < node.distance) {
            queue.remove(node);
            node.distance = d;
            node.previous = current;
            queue[node] = node;
          }
        }
      }
      queue.remove(current);
      current.visited = true;
      current = queue.firstKey();
    }
    
    var path = [];
    var n = end;
    while(n != null) {
      path.add(n);
      n = n.previous;
    }
    return path.reversed.toList();
  }

  Node getOrAddNode(String label) {
    Node n = new Node(label);
    if (nodes.contains(n)) {
      n = nodes.lookup(n);
    } else {
      nodes.add(n);
    }
    return n;
  }
}

void main(List<String> args) {
  if (args.length != 1 || !new File(args[0]).existsSync()) {
    exit(1);
  }
  var file = new File(args[0]);
  var lines = file.readAsLinesSync();
  var size = int.parse(lines.first.trim());
  var startAndEnd = lines.last.split(new RegExp(r'[ \t]+'));
  assert(startAndEnd.length == 2);
  var start = startAndEnd.first.trim();
  var end = startAndEnd.last.trim();
  assert(lines.length == size + 2);

  var m = new List<List<num>>();
  for (int i = 1; i <= size; i++) {
    m.add(lines[i].trim().split(',').map(num.parse).toList());
    assert(m.last.length == size);
  }
  var g = new Graph.fromDistanceMatrix(m);
  var path = g.shortestRoute(new Node(start), new Node(end));
  print(path.last.distance);
  print(path.map((n) => n.label).join(''));
}
