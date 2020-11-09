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

class Schedule {
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

  Schedule(String sureName, String name) {
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
