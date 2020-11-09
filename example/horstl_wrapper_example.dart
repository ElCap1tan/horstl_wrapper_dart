import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstl_wrapper/src/development/creds.dart';

void main() async {
  var c = Course('AIXXXX', 'T', 'T', 'E', 'S', 'T', 'T', 'E', 'S', 'T', '!');
  var d = Day('Monday', '50.60.8888');
  var s = Schedule('Wehner', 'Yannic');
  d.addCourse(c);
  s.days['monday'] = d;
  // print(t.toString());
  var hs = HorstlScrapper(FD_NUMBER, FD_PASSWORD);
  var schedule = await hs.getScheduleForWeek(50, 2020);
  print(schedule);
  var menu = await hs.getMenu(DateTime.now());
  menu.dishes.forEach((d) {
    print(d.name);
  });
}
