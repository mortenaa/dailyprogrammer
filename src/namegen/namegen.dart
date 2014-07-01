import 'dart:math';
import 'dart:collection';
import 'dart:io';

Random random = new Random();

class NameList {
  // Name files downloaded from 
  //    https://www.census.gov/genealogy/www/data/1990surnames/names_files.html
  static final MALE_NAMES_FILE = 'dist.male.first';
  static final FEMALE_NAMES_FILE = 'data/dist.female.first';
  static final LAST_NAMES_FILE = '/data/dist.all.last';
  List<String> firstNames = [];
  List<String> lastNames = [];
  NameList.fromFile() {
    firstNames.addAll(_read(MALE_NAMES_FILE));
    firstNames.addAll(_read(FEMALE_NAMES_FILE));
    lastNames.addAll(_read(LAST_NAMES_FILE));
  }
  
  List<String> _read(String filename) {
    return new File(filename).readAsLinesSync().map((s) => s.split(' ')[0]).toList();
  }
}

class RandomNames extends IterableBase {
  int   limit;
  NameList nameList;
  RandomNames(this.nameList, this.limit);
  Iterator<String> get iterator 
      => new _NameGenerator(limit, nameList.firstNames, nameList.lastNames);
}

class _NameGenerator implements Iterator<String> {
  List<String> firstNames;
  List<String> lastNames;
  int firstIndex;
  int lastIndex;
  int numIndex;
  int limit;
  
  _NameGenerator(this.limit, this.firstNames, this.lastNames) {
    numIndex = 0;
    firstIndex = 0;
    lastIndex = 0;
    firstNames.shuffle(random);
    lastNames.shuffle(random);
  }
  
  bool moveNext() {
    numIndex++;
    if (numIndex > limit) {
      return false;
    } 
    if (++firstIndex == firstNames.length) {
      firstIndex = 0;
      firstNames.shuffle();
    }
    if (++lastIndex == lastNames.length) {
      lastIndex = 0;
      lastNames.shuffle();
    }
    return true;
  }
  
  String get current {
    return firstNames[firstIndex] + ', ' + lastNames[lastIndex];
  }
}

String grades(int num) {
  var res=[];
  for (int i=0; i<num; i++) {
    res.add(random.nextInt(100));
  }
  return res.join(', ');
}

void main(List<String> args) {
  NameList names = new NameList.fromFile();
  for (var x in new RandomNames(names, int.parse(args[0]))) {
    print(x + ' ' + grades(5));
  }
}
