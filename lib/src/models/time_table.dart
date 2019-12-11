import '../../horstl_wrapper.dart';

class TimeTable {
  String studentName;
  String _sureName;
  String _name;
  Map<String, Day> days = {
    'monday': null,
    'tuesday': null,
    'wednesday': null,
    'thursday': null,
    'friday': null,
    'saturday': null,
  };

  TimeTable(String sureName, String name) {
    _sureName = sureName;
    _name = name;
    studentName = '$_name $_sureName';
  }

  @override
  String toString() {
    var r = '$studentName\n\n';
    days.forEach((k, d) => r += '${d}\n\n\n');
    return r;
  }
}