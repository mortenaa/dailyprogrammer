import 'dart:io';

List<List<num>> readDistanceMatrix(File file) {
  var lines = file.readAsLinesSync();
  var numRows = int.parse(lines[0].trim());
  var m = new List<List<num>>();
  for (int i = 1; i<=numRows; i++) {
    m.add(lines[i].trim().split(',').map(num.parse).toList());
  }
  return m;
}

class Edge {
  Node n1;
  Node n2;
  num weight;
  String label;
  Edge(this.label);
  bool operator==(other) => label == other.label;
  int get hashCode => label.hashCode;
  String toString() => '$label($weight): ${n1.label}-${n2.label}';
}

class Node {
  Set<Edge> edges = new Set();
  String label;
  Node(this.label);
  bool operator==(other) => label == other.label;
  int get hashCode => label.hashCode;
  String toString() => '$label[${edges.length}]';
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
        if(w >= 0) {
          Node n1 = getOrAddNode(labels[i]);
          Node n2 = getOrAddNode(labels[j]);
          Edge e = new Edge(labels[i] + labels[j]);
          e.weight = w;
          n1.edges.add(e);
          n2.edges.add(e);
          e.n1 = n1;
          e.n2 = n2;
          edges.add(e);
        }
      }
    }
  }
  
   List<Edge> minimumSpanningTree() {
    List<List<Edge>> forrest = [];
    List<Edge> edgeSet = [];
    edges.forEach((e) {
      edgeSet.add(e);
    });
    edgeSet.sort((e1, e2) => e2.weight - e1.weight);
    //print(edgeSet);
    nodes.forEach((n) {
      Edge dummy = new Edge(n.label + n.label);
      dummy.n1=n;
      dummy.n2=n;
      forrest.add([dummy]);
    });
    while (forrest.length > 1) {
      Edge edge = edgeSet.removeLast();
      List<Edge> s1, s2;
      forrest.forEach((List<Edge> es) {
        es.forEach((Edge e) {
          if (edge.n1 == e.n1 || edge.n1 == e.n2) {
            s1 = es;
          }
          if (edge.n2 == e.n1 || edge.n2 == e.n2){
            s2 = es;
          }
        });
      });
      if (s1 != s2) {
        forrest.remove(s1);
        s2.add(edge);
        s2.addAll(s1);
      }
    }
    forrest.first.removeWhere((Edge e) => e.n1 == e.n2);
    return forrest.first;
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
  
  Node nodeAt(String label) => nodes.lookup(new Node(label));
  
  Edge edgeAt(String label) => edges.lookup(new Edge(label));
}

void main(List<String> args) {
  if (args.length != 1 || !new File(args[0]).existsSync()) {
    exit(1);
  }
  var file = new File(args[0]);
  var matrix = readDistanceMatrix(file);
  Graph g = new Graph.fromDistanceMatrix(matrix);
  List<Edge> mst = g.minimumSpanningTree();
  int weight = 0;
  mst.forEach((e) {
    weight += e.weight;
  });
  print(weight);
  print(mst.map((e) => e.label).join(','));
}