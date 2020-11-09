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

import 'dart:async';
import 'dart:convert';

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

  HorstlScrapper(String fdNumber, String passWord) {
    _fdNumber = fdNumber;
    _passWord = passWord;
  }

  Future<Schedule> getScheduleForCurrentWeek() async {
    var today = DateTime.now();
    return getScheduleForWeek(today.weekOfYear, today.year);
  }

  Future<Schedule> getScheduleForWeek(int calendarWeek, int year) async {
    var doc = parse(await _getScheduleSrc(calendarWeek, year));

    var greeting = doc.getElementById('hisinoneTitle').text;
    var names = greeting
        .replaceFirst('\n			Stundenplan für ', '')
        .replaceFirst(' ', '')
        .split(',');

    var sureName = names[0].trim();
    var name = names[1].trim();

    var schedule = Schedule(sureName, name);
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
      schedule.days[dayLabels[currentDay]] = day;
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
    return schedule;
  }

  Future<String> _getScheduleSrcOfCurrentWeek() async {
    if (_sessionID == null) {
      await _authenticate();
    }
    var headers = <String, String>{'Cookie': 'JSESSIONID=$_sessionID'};
    var response =
        await get(Uri.parse('$_BASE_URL${Pages.TIME_TABLE}'), headers: headers);
    return response.body;
  }

  Future<String> _getScheduleSrc(int calendarWeek, int year) async {
    var currentWeekSrc = await _getScheduleSrcOfCurrentWeek();
    var doc = await parse(currentWeekSrc);

    var greeting = doc.getElementById('hisinoneTitle').text;
    var names = greeting
        .replaceFirst('\n			Stundenplan für ', '')
        .replaceFirst(' ', '')
        .split(',');

    var sureName = names[0].trim();
    var name = names[1].trim();

    var today = DateTime.now();

    if (today.weekOfYear == calendarWeek && today.year == year) {
      return currentWeekSrc;
    }

    var currentWeekDom = parse(currentWeekSrc);
    var jsForm = currentWeekDom.getElementById('jsForm');
    var endpointURL = jsForm.attributes['action'].substring(10);
    var viewState = endpointURL
        .substring(endpointURL.lastIndexOf('&') + 1)
        .replaceFirst('_flowExecutionKey=', '');
    var authenticityToken =
        _getChildByAttribute(jsForm, 'name', 'authenticity_token')
            .attributes['value'];

    var headers = <String, String>{
      'Cookie': 'JSESSIONID=$_sessionID',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Faces-Request': 'partial/ajax',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    };
    var body = <String, String>{
      'AJAX:EVENTS_COUNT': '1',
      'activePageElementId':
          'plan:scheduleConfiguration:anzeigeoptionen:refreshSelectedWeek',
      'refreshButtonClickedId': '',
      'navigationPosition': 'hisinoneMeinStudium,individualTimetableSchedule',
      'authenticity_token': authenticityToken,
      'autoScroll': '',
      'javax.faces.ViewState': viewState,
      'javax.faces.behavior.event': 'action',
      'javax.faces.partial.ajax': 'true',
      'javax.faces.partial.event': 'click',
      'javax.faces.partial.execute': 'plan',
      'javax.faces.partial.render': 'plan plan:messages-infobox',
      'javax.faces.source':
          'plan:scheduleConfiguration:anzeigeoptionen:refreshSelectWeek',
      'plan': 'plan',
      'plan:schedule:scheduleLegend:rhythmLegend:collapsiblePanelCollapsedState':
          'false',
      'plan:scheduleConfiguration:anzeigeoptionen:collapsiblePanelCollapsedState':
          'false',
      'plan:scheduleConfiguration:anzeigeoptionen:auswahl_zeitraum': 'woche',
      'plan:scheduleConfiguration:anzeigeoptionen:auswahl_zeitraumInput':
          'Wochenauswahl',
      'plan:scheduleConfiguration:anzeigeoptionen:selectWeek':
          '${calendarWeek}_$year',
      'plan_SUBMIT': '1',
      'rfExt': 'null',
      'DISABLE_VALIDATION': '1',
    };

    var response = await post(Uri.parse('$_BASE_URL${endpointURL}'),
        body: body, headers: headers, encoding: Encoding.getByName('utf-8'));
    var scheduleHTML = '<' +
        response.body.substring(
            response.body.indexOf('<![CDATA[') + '<![CDATA['.length + 1);
    scheduleHTML = scheduleHTML.substring(0, scheduleHTML.indexOf(']]>'));
    return '<p id="hisinoneTitle">$name,$sureName</p>$scheduleHTML';
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
      if (imgTag.isNotEmpty &&
          !imgTag[0].attributes['src'].contains('dummyessen')) {
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
  }

  Element _getChildByAttribute(Element parent, String attrib, String value) {
    return parent.nodes.firstWhere((node) {
      if (node.attributes.containsKey(attrib)) {
        return node.attributes[attrib] == value;
      }
      return false;
    }, orElse: () {
      var e = Element.tag('p');
      e.text = 'N/A';
      return e;
    });
  }

  Element _getChildById(Element child, String id) {
    return _getChildByAttribute(child, 'id', id);
  }
}
