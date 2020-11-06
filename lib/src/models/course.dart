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
