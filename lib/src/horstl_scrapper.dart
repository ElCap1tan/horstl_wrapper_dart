import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:horstl_wrapper/src/models/dish.dart';
import 'package:horstl_wrapper/src/models/menu.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';

import 'package:horstl_wrapper/horstl_wrapper.dart';

abstract class Pages {
  static final String HOMEPAGE =
      '/pages/cs/sys/portal/hisinoneStartPage.faces?page=1';
  static final String LOGIN = '/rds?state=user&type=1&category=auth.login';
  static final String TIME_TABLE =
      '/pages/plan/individualTimetable.xhtml?_flowId=individualTimetableSchedule-flow';
  static final String MENU =
      'https://www.studentenwerk-giessen.de/xhr/speiseplan-wochentag.html';
}

class HorstlScrapper {
  static final String _BASE_URL = 'https://horstl.hs-fulda.de/qisserver';
  String _fdNumber;
  String _passWord;
  String _sessionID;
  final HttpClient _session = HttpClient();

  HorstlScrapper(String fdNumber, String passWord) {
    _fdNumber = fdNumber;
    _passWord = passWord;
  }

  Future<TimeTable> getTimeTable() async {
    var doc = parse(await _getTimeTableSrc());

    var greeting = doc.getElementById('hisinoneTitle').text;
    var names = greeting
        .replaceFirst('\n			Stundenplan für ', '')
        .replaceFirst(' ', '')
        .split(',');

    var sureName = names[0].trim();
    var name = names[1].trim();

    var tt = TimeTable(sureName, name);
    var dayLabels = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];

    var rawDays = doc.getElementsByClassName('column');

    var currentDay = 0;
    for (var dayHTML in rawDays) {
      var dateInfo = dayHTML
          .getElementsByClassName('colhead')[0]
          .text
          .replaceFirst(' ', '')
          .replaceAll('\n', '')
          .split(',');
      var dow = dateInfo[0];
      var date = dateInfo[1];
      var day = Day(dow, date);
      tt.days[dayLabels[currentDay]] = day;
      for (var schedule = 0;
          schedule < dayHTML.getElementsByClassName('schedulePanel').length;
          schedule++) {
        var panel = _getChildById(
            dayHTML.getElementsByClassName('singleblock')[schedule],
            'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:schedulePanelGroup');

        var id = _getChildById(
                _getChildById(panel,
                    'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:course_detail_link'),
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:scheduleElementnr_')
            .text
            .trim();

        var name = _getChildById(
                _getChildById(panel,
                    'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:course_detail_link'),
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:scheduleDefaulttext_')
            .text
            .trim();

        var kind = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:eventtypeShorttext')
            .text
            .trim();
        var group = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:parallelgroupshorttext')
            .text
            .replaceFirst(',', '')
            .trim();
        var time = _getChildById(
                panel.getElementsByClassName('scheduleTimes')[0],
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:times')
            .text
            .trim()
            .replaceFirst('bis', ' bis ');
        var frequency = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:rhythmDefaulttext')
            .text
            .trim();

        var startDate = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:scheduleStartDate')
            .text
            .trim();
        startDate = startDate != 'N/A' ? startDate : '';
        var endDate = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:scheduleEndDate')
            .text
            .trim();
        endDate = endDate != 'N/A' ? endDate : '';
        var timePeriod = startDate +
            (startDate != '' && endDate != '' ? ' - ' : '') +
            endDate;

        var roomInfo = _getChildById(panel,
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:roomDefaulttext:showRoomDetailLink')
            .text
            .trim();
        var docent = panel.getElementsByTagName('a')[0].text;
        var status = _getChildById(
                _getChildById(panel,
                    'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:scheduleItemWorkstatus'),
                'plan:schedule:scheduleColumn:$currentDay:termin:$schedule:scheduleItem:workstatusLongtext')
            .text
            .trim();

        var warning;

        var course = Course(id, name, kind, group, time, frequency, timePeriod,
            roomInfo, docent, status, warning);
        day.addCourse(course);
      }
      currentDay++;
    }
    return tt;
  }

  Future<String> _getTimeTableSrc() async {
    if (_sessionID == null) {
      await _authenticate();
    }
    var response = await _session
        .getUrl(Uri.parse('$_BASE_URL${Pages.TIME_TABLE}'))
        .then((HttpClientRequest request) {
      request.headers.add('Cookie', 'JSESSIONID=$_sessionID');
      return request.close();
    });
    return _readResponse(response, utf8.decoder);
  }

  Future<String> _getMenuSrc(DateTime day) async {
    var body = <String, String>{};
    body['resources_id'] = '34';
    body['date'] =
        '${day.year}-${day.month}-${day.day < 10 ? '0' + day.day.toString() : day.day}';
    // body['week'] = day.weekOfYear == DateTime.now().weekOfYear ? 'now': 'next';
    var response = await post(Uri.parse(Pages.MENU), body: body);
    return response.body;
  }

  Future<Menu> getMenu(DateTime day) async {
    var menuDoc = parse(await _getMenuSrc(day));
    var dishes = menuDoc.getElementsByClassName('rowMeal');
    var menu = Menu('${day.year}-${day.month}-${day.day}');

    for (var i = 0; i < dishes.length; i++) {
      var t = dishes[i].getElementsByClassName(
          'col-12 mb-10 order-12 col-sm-6 order-sm-1 mb-sm-0')[0];
      var name = t.getElementsByTagName('span')[0].text.trim();
      var description = t.text.replaceFirst(name, '').trim();
      var price = dishes[i]
          .getElementsByClassName('d-block col-12 order-1 d-sm-none pt-2')[1]
          .text
          .trim();
      var imgURL =
          'https://image.freepik.com/free-photo/wooden-texture_1208-334.jpg';
      var imgTag = dishes[i].getElementsByTagName('img');
      if (imgTag.isNotEmpty) {
        imgURL = imgTag[0].attributes['src'];
      }
      var dish = Dish(name, description, price, imgURL);
      menu.addDish(dish);
    }
    return menu;
  }

  void _authenticate() async {
    var loginURL = '$_BASE_URL${Pages.LOGIN}';
    var cli = Client();
    var formData = {
      'asdf': _fdNumber,
      'fdsa': _passWord,
    };
    var r = await cli.post(loginURL, body: formData);
    var cookies = r.headers['set-cookie'].split(';');
    _sessionID = cookies[0].substring(0, cookies[0].length).split('=')[1];
    // print(_sessionID);
  }

  // Helpers
  Future<String> _readResponse(HttpClientResponse response,
      StreamTransformerBase<List<int>, String> decoder) {
    var completer = Completer<String>();
    var contents = StringBuffer();
    response.transform(decoder).listen((data) {
      if (data is String) {
        contents.write(data);
      }
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  Element _getChildById(Element child, String id) {
    return child.nodes.firstWhere((node) {
      if (node.attributes.containsKey('id')) {
        return node.attributes['id'] == id;
      }
      return false;
    }, orElse: () {
      var e = Element.tag('p');
      e.text = 'N/A';
      return e;
    });
  }
}
