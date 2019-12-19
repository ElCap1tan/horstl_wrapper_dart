import 'package:horstl_wrapper/horstl_wrapper.dart';

class Day {
  //FIELDS
  String _dow;
  String _date;
  final List _courses = [];

  //CONSTRUCTOR
  Day(String dow, String date) {
    _dow = dow;
    _date = date;
  }

  void addCourse(Course c) => _courses.add(c);

  @override
  String toString() {
    var separatorLength = 40;
    var r = '${_capitalize(_dow)} - ${_date}:\n';
    r += '-' * (separatorLength * 2) + '\n\n';
    if (_courses.isNotEmpty) {
      for (Course c in _courses) {
        r += '~' * separatorLength + '\n';
        r += c.toString();
        r += '~' * separatorLength + '\n';
      }
    }
    else {
      r += 'Nothing to show here. Looks like a free day :)\n\n';
    }
    r += '-' * (separatorLength * 2) + '\n\n';
    return r;
  }

  //SETTERS AND GETTERS
  String dow() => _dow;
  String date() => _date;
  List courses() => _courses;
  // --------------------------------------------------------------------------
  void setDate(String d) => _date = d;
  void setDOW(String dow) => _dow = dow;

  String _capitalize(String s) {
    return s.replaceFirst(s[0], s[0].toUpperCase());
  }
}