import 'dart:io';

class Dictionary {
  Set _dict = new Set<String>();

  Dictionary.fromFile(File file) {
    _dict.addAll(file.readAsLinesSync().map((l) => l.trim()));
    _dict.remove('si');
    _dict.add('a');
  }

  bool contains(String word) => 
      _dict.contains(word.trim().toLowerCase());
}

class SpellChecker {
  Dictionary _dict;
  List<String> _keyboardRows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
  Map<String, List<String>> _keyMap = new Map<String, List<String>>();

  SpellChecker(this._dict) {
    var rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm']
              .map((r) => r.split(''));
    for (List<String> row in rows) {
      for (int i = 0; i < row.length; i++) {
        var cs = [];
        for (int j = i - 2; j <= i + 2; j++) {
          cs.add(row[j % row.length]);
        }
        _keyMap[row[i]] = cs;
      }
    }
  }
  
  String shiftWord(String word, int n) {
    assert(-2 <= n && n <= 2);
    return word.split('').map((c) => _keyMap[c][n+2]).join('');
  }
  
  String spellings(String word) {
    List<String> words = [];
    word = word.toLowerCase();
    if (_dict.contains(word)) {
      return word;
    } else {
      for (int i = -2; i <= 2; i++) {
        var w = shiftWord(word, i);
        if (_dict.contains(w)) {
          words.add(w);
        }
      }
    }
    return '{' + words.join(' ') + '}';
  }
}
void main(List<String> args) {
  assert(args.length == 2);
  var files = args.map((f) => new File(f));
  assert(files.every((f) => f.existsSync()));
  var dictionary = files.first;
  File input = files.last;
  var dict = new Dictionary.fromFile(dictionary);
  var spell = new SpellChecker(dict);
  var sb = new StringBuffer();
  ;
  var string = input.readAsStringSync()
      .replaceAllMapped(new RegExp(r'\w+'), (Match m) => 
                                            spell.spellings(m[0]));
  print(string);
  
  
}