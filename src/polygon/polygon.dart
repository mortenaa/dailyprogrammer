import 'dart:io';

void main(List<String> args) {
  if (args.length != 1 || !new File(args[0]).existsSync()) {
    exit(1);
  }
  var v = new File(args.first).readAsLinesSync()
      .map((l) => l.trim().split(',').map((n) => num.parse(n)).toList())
      .toList();
  var N = v.removeAt(0).first;
  assert(N == v.length);
  var sum = 0;
  for (var i=0; i<N; i++) {
    var p1 = v[i],
        p2 = v[(i + 1) % N];
    sum += p1[0] * p2[1] - p2[0] * p1[1];
  }
  print((sum/2).abs());
}