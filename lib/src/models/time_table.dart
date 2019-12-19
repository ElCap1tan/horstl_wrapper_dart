import '../../horstl_wrapper.dart';

class TimeTable {
  String studentName = 'N/A';
  String _sureName = 'N/A';
  String _name = 'N/A';
  Map<String, Day> days = {
    'monday': Day('Mo.', 'N/A'),
    'tuesday': Day('Di.', 'N/A'),
    'wednesday': Day('Mi.', 'N/A'),
    'thursday': Day('Do.', 'N/A'),
    'friday': Day('Fr.', 'N/A'),
    'saturday': Day('Sa.', 'N/A'),
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