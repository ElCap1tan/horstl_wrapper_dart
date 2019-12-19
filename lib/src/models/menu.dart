import 'package:horstl_wrapper/src/models/dish.dart';

class Menu {
  String date;
  List<Dish> dishes = [];

  Menu(this.date);

  void addDish(Dish dish) {
    dishes.add(dish);
  }
}