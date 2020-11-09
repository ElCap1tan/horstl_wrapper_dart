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

import 'package:horstl_wrapper/src/models/dish.dart';

class Menu {
  String date;
  List<Dish> dishes = [];

  Menu(this.date);

  void addDish(Dish dish) {
    dishes.add(dish);
  }
}
