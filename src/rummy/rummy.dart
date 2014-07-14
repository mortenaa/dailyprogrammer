import 'dart:io';

class Card {
  static final Suites = ['clubs', 'diamonds', 'hearts', 'spades'];
  static final Ranks = ['', 'ace', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 
                            'nine', 'ten', 'jack', 'queen', 'king'];
  int rank;
  int suit;
  Card(this.rank, this.suit);
  String toString() => '${Ranks[rank]} of ${Suites[suit]}';
}

void main(List<String> args) {
  var c = new Card(1, 3);
  print(c);
}