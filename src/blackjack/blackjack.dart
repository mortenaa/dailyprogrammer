import 'dart:io';

class Game {
  List<Hand> hands;
  
  sort() {
    hands.sort((var h1, var h2) => h2.value - h1.value);
  }
  
  String winner() {
    sort();
    var best = hands.first;
    if (hands.where((var h) => h.value == best.value).length > 1) {
      return 'Tie';
    } else if (best.cards == 5) {
      return '${best.player} has won with a 5-card trick!';
    } else {
      return '${best.player} has won!';
    }
  }
}

class Hand {
  static final Map<String, int> cardValues = {
    'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 
    'nine': 9, 'ten': 10, 'jack': 10, 'queen': 10, 'king': 10, 'ace': 11
  };
  String player;
  int value = 0;
  int cards = 0;
  
  Hand.parse(String s) {
    var t = s.trim().split(':');
    player = t.first;
    int aces = 0;
    t.last.trim().split(',').forEach((c) {
      cards++;
      var f = c.trim().split(' ').first.toLowerCase();
      var val = cardValues[f];
      value += val;
      if (f == 'ace') {
        aces++;
      }
    });
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    if (value > 21) {
      value = 0;
    }
    if (cards == 5 && value > 0) {
      value = 22;
    }
  }
}

void main(List<String> args) {
  var lines = new File(args.first).readAsLinesSync();
  var games = new List<Game>();
  while (lines.length > 0) {
    var n = num.parse(lines.removeAt(0).trim());
    var g = new Game()
      ..hands = lines.sublist(0, n).map((s) => new Hand.parse(s)).toList();
    lines.removeRange(0, n);
    games.add(g);
  }
  for (var g in games) {
    print(g.winner());
  }
}