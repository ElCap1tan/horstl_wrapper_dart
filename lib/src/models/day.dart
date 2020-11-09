// horstl_wrapper - Wrapper for the online student organization
// system (horstl.hs-fulda.de) of the University Fulda.
//
// Copyright (C) 2020  Yannic Wehner
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see https://www.gnu.org/licenses/.

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
    } else {
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
