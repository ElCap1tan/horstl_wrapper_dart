import 'package:horstl_wrapper/horstl_wrapper.dart';
import '../lib/src/development/creds.dart';

void main() async {
  var c = Course('AIXXXX', 'T', 'T', 'E', 'S', 'T', 'T', 'E', 'S', 'T', '!');
  var d = Day('Monday', '50.60.8888');
  var t = TimeTable('Wehner', 'Yannic');
  d.addCourse(c);
  t.days['monday'] = d;
  // print(t.toString());
  var hs = HorstlScrapper(FD_NUMBER, FD_PASSWORD);
  var tt = await hs.getTimeTable();
  print(tt);
  var menu = await hs.getMenu(DateTime.now());
  menu.dishes.forEach((d) {
    print(d.name);
  });
  // print(menu.dishes.length);
  // for (var dish in menu.dishes) {
  //   print(dish.imgURL);
  // }
}
