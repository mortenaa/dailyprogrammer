import 'dart:math';
import 'dart:io';

Random random = new Random();
final int PLAYERS = 32;

class NameList {
  static final MALE_NAMES_FILE = 'dist.male.first';
  static final FEMALE_NAMES_FILE = 'dist.female.first';
  static final LAST_NAMES_FILE = 'dist.all.last';
  List<String> firstNames = [];
  List<String> lastNames = [];
  
  NameList.fromFile() {
    firstNames.addAll(readNames(MALE_NAMES_FILE));
    firstNames.addAll(readNames(FEMALE_NAMES_FILE));
    lastNames.addAll(readNames(LAST_NAMES_FILE));
  }
  
  List<String> readNames(String filename) {
    return new File(filename).readAsLinesSync().map(
        (s) => s.split(' ')[0]
    ).toList();
  }
  
  String randomName() {
    int r1 = random.nextInt(firstNames.length);
    int r2 = random.nextInt(lastNames.length);
    return '${firstNames[r1]} ${lastNames[r2]}';
  }
}

class Player {
  String name;
  List<int> points = [];
  int total = 0;
  int id;
  List<int> scores;
  static final int HOME = 0;
  static final int AWAY = 1;
  static final int TIE = 2;
  static int NEXT_ID = 0;
  static int round = 0;
  
  Player(this.name) {
    this.id = NEXT_ID++;
  }
  
  int play(Player other) {
    this.points.add(0);
    other.points.add(0);
    var winner, loser;
    bool tie = false;
    double d = random.nextDouble();
    int result;
    if (d < 0.4) {
      winner = this;
      loser = other;
      result = HOME;
    } else if (d < 0.8) {
      winner = other;
      loser = this;
      result = AWAY;
    } else {
      tie = true;
      result = TIE;
    }
    if (tie) {
      this.points[round] += 10;
      other.points[round] += 10;
    } else {
      winner.points[round] += 15;
      loser.points[round] += 5;
    }
    this.points[round] += (random.nextInt(11) - 5);
    other.points[round] += (random.nextInt(11) - 5);
    this.total += this.points[round];
    other.total += other.points[round];
    return result;
  }
  
  bool operator==(other) => name == other.name;
  
  int get hashCode => name.hashCode;
  
  String toString() => this.name;
}

class Tournament {
  Map playerMap = new Map<Player, Map<Player, bool>>();
  List players;
  Tournament(this.players) {
    for (var p in players) {
      playerMap[p] = new Map<Player, bool>();
      for (var q in players) {
        playerMap[p][q] = false;
      }
    }
  }
  
  List<List<Player>> pairings() {
    players.shuffle(random);
    players.sort((p1, p2) => p2.total - p1.total);
//    var matches = [];
//    for (var i = 0; i < players.length; i += 2) {
//      matches.add([players[i], players[i+1]]);
//    }
    var stack = [];
    var available = [];
    var matched = [];
    var matches = [];
    for (var v = 0; v < players.length; v++) {
      available.add(v);
    }
    var n = (players.length / 2).floor();
    Player nextCandidate(Player p1) {
      for (int i = 0; i < players.length; i++) {
        var p2 = players[i];
        if (!playerMap[p1][p2] && !matched.contains(p2)) {
          return p2;
        }
      }
      return null;
    }
    Player nextPlayer() {
      for (int i = 0; i < players.length; i++) {
        var p1 = players[i];
        if (!matched.contains(p1)) {
          return p1;
        }
      }
      return null;
    }
    stack.add([players.first, nextCandidate(players.first)]);
    bool done = false;
    
    while (!done || stack.length < n) {
      var p1 = nextPlayer();
      if (p1 == null) {
        // all players have been assigned
        done = true;
      } else {
        var p2 = nextCandidate(p1);
        if (p2 == null) {
          // No candidate to play p1, backtrack!
          var v = stack.last;
        } else {
          matched.addAll([p1, p2]);
          stack.add([p1, p2]);
        }
      }
    }
    while (true) {
      var v = available.removeAt(0);
      var w = available.firstWhere((e) => !playerMap[v][e], orElse:() => null);
      if (w != null) {
        stack.add([v, w]);
      } else {
        var p = stack.removeLast();
        
      }
    }
    
    return matches;
  }
  
  playRound() {
    var matches = pairings();
    for (var m in matches) {
      var p1 = m[0],
          p2 = m[1];
      var r = p1.play(p2);
      print('${p1} vs ${p2}: ${r == Player.TIE ? "Tie" : m[r].name + " Wins"}');
      playerMap[p1][p2] = true;
      playerMap[p2][p1] = true;
    }
    Player.round++;
  }
  
  printTable() {
    players.sort((p1, p2) => p2.total - p1.total);
    int rank = 0;
    var str = new StringBuffer();
    str.write('Rank'.padRight(5));
    str.write('Player'.padRight(25));
    str.write('ID'.padRight(8));
    for (var r = 1; r <= players.first.points.length; r++) {
      str.write('Rnd$r'.padRight(6));
    }
    str.write('Total'.padRight(5));
    stdout.writeln(str);
    stdout.writeln(''.padLeft(str.length, '='));
    for (var p in players) {
      rank++;
      stdout.write(rank.toString().padRight(5));
      stdout.write(p.name.padRight(25));
      stdout.write(p.id.toString().padRight(8));
      for (var s in p.points) {
        stdout.write(s.toString().padRight(6));
      }
      stdout.write(p.total.toString().padRight(5));
      stdout.write('\n');
    }
  }
}

void main(List<String> args) {
  NameList names = new NameList.fromFile();
  var players = new Map();
  while (players.length < PLAYERS) {
    var name = names.randomName();
    if (!players.containsKey(name)) {
      players[name] = new Player(name);
    }
  }
  var t = new Tournament(players.values.toList());
  for (int i = 0; i < 6; i++) {
    t.playRound();
    t.printTable();
  }

}
