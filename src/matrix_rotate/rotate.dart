/// Challenge #169 [Easy] 90 Degree 2D Array Rotate

import 'dart:io';

class Matrix {
  List<List<num>> matrix;
  int size;
  
  Matrix.fromFile(File file) {
    var ws = new RegExp(r'[ \t]+');
    matrix = file.readAsLinesSync()
        .map((l) => l.split(ws).map((n) => num.parse(n.trim())).toList())
        .toList();
    size = matrix.length;
    matrix.forEach((r) {assert(r.length == size);});
  }
  
  String toString() {
    var s = new StringBuffer();
    matrix.forEach((l) {
      s.writeln(l.map((n) => n.toString().padLeft(2)).join(' '));
    });
    return s.toString();
  }
  
  rotate() {
    int n = size - 1;
    int c = (n/2).floor();  
    num tmp;
    
    for(int x = 0; x < c; x++) {
      for(int y = x; y < n - x; y++) {
        tmp = matrix[x][y];
        matrix[x][y] = matrix[n-y][x];
        matrix[n-y][x] = matrix[n-x][n-y];
        matrix[n-x][n-y] = matrix[y][n-x];
      }
    }
  }
}

void main(List<String> args) {
  if (args.length != 1) {
    exit(1);
  }
  var file = new File(args[0]);
  if (!file.existsSync()) {
    exit(1);
  }
  var matrix = new Matrix.fromFile(file);
  print('Original \n$matrix');
  matrix.rotate();
  print('Rotated 90° \n$matrix');
  matrix.rotate();
  print('Rotated 180° \n$matrix');
  matrix.rotate();
  print('Rotated 270° \n$matrix');
}