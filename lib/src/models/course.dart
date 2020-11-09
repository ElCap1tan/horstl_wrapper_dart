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

class Course {
  // FIELDS
  String _id;
  String _name;
  String _kind;
  String _group;
  String _time;
  String _frequency;
  String _timePeriod;
  String _roomInfo;
  String _docent;
  String _status;
  String _warning;

  //CONSTRUCTOR
  Course(
      String id,
      String name,
      String kind,
      String group,
      String time,
      String frequency,
      String timePeriod,
      String roomInfo,
      String docent,
      String status,
      String warning) {
    _id = id;
    _name = name;
    _kind = kind;
    _group = group;
    _time = time;
    _frequency = frequency;
    _timePeriod = timePeriod;
    _roomInfo = roomInfo;
    _docent = docent;
    _status = status;
    _warning = warning;
  }

  @override
  String toString() {
    var r = 'ID: $_id\n'
        'Name: $_name\n'
        'Typ: $_kind\n'
        'Parralelgruppe: $_group\n'
        'Zeit: $_time\n'
        'Frequenz: $_frequency\n'
        'Zeitraum: $_timePeriod\n'
        'Rauminfo: $_roomInfo\n'
        'Dozent/in: $_docent\n'
        'Status: $_status\n';
    if (_warning != null) {
      r += 'Warnung: $_warning\n';
    }
    return r;
  }

  // GETTER AND SETTERS
  String id() => _id;
  String name() => _name;
  String kind() => _kind;
  String group() => _group;
  String time() => _time;
  String frequency() => _frequency;
  String timePeriod() => _timePeriod;
  String roomInfo() => _roomInfo;
  String docent() => _docent;
  String status() => _status;
  String warning() => _warning;
}
