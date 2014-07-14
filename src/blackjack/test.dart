import 'dart:io';

void main(List<String> args) {
  
  var names = new File(args.first).readAsLinesSync().map((line) => line.trim()).toList().sublist(1);
  print(names);
  
  assert(args.length > 0);
  var file = new File(args.first);
  var lines = file.readAsLinesSync();
  var num = int.parse(lines.removeAt(0).trim());
  assert(num == lines.length);
  var nameList = lines.map((line) => line.trim()).toList();
  print(nameList);
  
  stdout.write('Enter number of names: ');
  var n = int.parse(stdin.readLineSync().trim());
  var list = [];
  for (var i = 0; i < n; i++) {
    stdout.write('Name ${i+1}: ');
    list.add(stdin.readLineSync().trim());
  }
  print(list);
}