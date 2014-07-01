import 'dart:io';

void main(List<String> args) {
  if (args.length != 1 || !new File(args[0]).existsSync()) {
    exit(1);
  }
  var file = new File(args[0]);
  var lines = file.readAsLinesSync();
  Plan plan = new Plan(lines);
  plan.printSummary();
}

class Coord {
  int row;
  int col;
  Coord(this.row, this.col);
  bool operator==(other) => row == other.row && col == other.col;
  int get hashCode => row.hashCode + col.hashCode;
}

class Group {
  String char;
  Set<Coord> entries;
  int length=0;
  int get area => entries.length;
  Group(this.char, this.entries);
  String toString() => '$char/${entries.length}';
}

class Plan {
  List plan = [];
  int width;
  int height;
  Group nullGroup = new Group(' ', null);
  Plan(lines) {
    this.height = lines.length;
    this.width = lines[0].length;
    for (var line in lines) {
      var row = [];
      assert(line.length == width);
      for (var s in line.split('')) {
        var c = new Coord(plan.length, row.length);
        var set = new Set();
        set.add(c);
        var g = new Group(s, set);
        g.length = 4;
        row.add(g);
      }
      plan.add(row);
    }
  }
  
  printSummary() {
    Set<Group> groups = survey();
    var map = {};
    for (var g in groups) {
      if (map.containsKey(g.char)) {
        map[g.char].add(g);
      } else {
        map[g.char] = [g]; 
      }
    }
    for (var c in map.keys) {
      var sf=0;
      var lf=0;
      var blocks=0;
      for (var b in map[c]) {
        blocks++;
        lf += b.length;
        sf += b.area;
      }
      var plural=blocks==1?'':'s';
      print('$c: Total SF (${sf*100}), Total Circumference LF (${lf*10}) - Found $blocks block$plural');
    }
  }

  Set<Group> survey() {
    var groups = new Set<Group>();
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        Group here = plan[row][col];
        String char = here.char;
        Group above = null;
        Group left = null;
        Coord c = new Coord(row, col);
        
        groups.add(here);
        
        bool added=false;
        
        if (row > 0) {
          // look above
          above = plan[row - 1][col];
          if (above.char == char) {
            added = true;
            above.entries.add(c);
            above.length += 2;
            plan[c.row][c.col] = above; 
            groups.remove(here);
          }
        }
        if (col > 0) {
          // look left
          left = plan[row][col - 1];
          if (left.char == char) {
            left.entries.add(c);
            if (above != left) {
              left.length += 2;
            } else {
              left.length -= 2;
            }
            plan[c.row][c.col]= left; 
            groups.remove(here);
          }
        }

        if (above != null && left != null) {
          if (above.char == left.char && char == left.char && above != left) {
            // Join groups above and to the left
            var g = new Group(char, above.entries.union(left.entries));
            g.entries.add(c);
            g.length=above.length + left.length - 4;
            //here.entries = above.entries.union(left.entries);
            for (var c in g.entries) {
              plan[c.row][c.col] = g;
            }
            groups.add(g);
            groups.remove(left);
            groups.remove(above);
            groups.remove(here);
          }
        }
      }
    }
    return groups;
  }
}
