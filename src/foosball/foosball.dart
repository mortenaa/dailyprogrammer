import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  if (args.length != 1 || !new File(args[0]).existsSync()) {
    exit(1);
  }
  var file = new File(args[0]);
  var lines = file.readAsLinesSync();
  var N = int.parse(lines.first.trim());
  assert(N == lines.length - 1);
  var M = largestPowerOfTwo(N);
  var rng = new Random();
  var teams = lines.sublist(1).map((l) => l.trim()).toList();
  teams.shuffle(rng);
  var rounds = [];

  var E = N - M;
  int matchIndex = 'A'.codeUnits.first;
  if (E > 0) {
    var Q = 2 * E;
    var qRound = [];
    var winners = [];
    print('Qualification Round:\n');
    for (int i = 0; i < E; i++) {
      var team1 = teams.removeLast();
      var team2 = teams.removeLast();
      var id = new String.fromCharCode(matchIndex);
      qRound.add([id, team1, team2]);
      winners.add('[Winner of $id]');
      print('  $id) $team1 - $team2');
      matchIndex++;
    }
    rounds.add(qRound);
    teams.addAll(winners);
  }
  
  int numRounds = log2(M);
  for (int i = numRounds; i > 0; i--) {
    var roundName = 'Round ${numRounds-i+1}';
    if (i == 1) roundName = 'Final';
    if (i == 2) roundName = 'Semi Finals';
    if (i == 3) roundName = 'Quarter Finals';

    print('\n$roundName:\n');
    int numTeams = pow(2, i);
    teams.shuffle(rng);
    var winners = [];
    var bronze = [];
    for (int j = 0; j < numTeams/2; j++) {
      var team1 = teams.removeLast();
      var team2 = teams.removeLast();
      var id = new String.fromCharCode(matchIndex);
      winners.add('[Winner of $id]');
      print('  $id) $team1 - $team2');
      if (i == 2) {
        bronze.add('[Loser of $id]');
      }
      matchIndex++;
    }
    if (i == 2) {
      assert(bronze.length == 2);
      var team1 = bronze.removeLast();
      var team2 = bronze.removeLast();
      var id = new String.fromCharCode(matchIndex);
      print('\nBronze Final:\n');
      print('  $id) $team1 - $team2');
      matchIndex++;
    }
    teams.addAll(winners);
  }
}

int log2(int n) => (log(n)/log(2)).floor();
int largestPowerOfTwo(int n) => pow(2,log2(n));
