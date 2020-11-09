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

/// Wrapper for the online student organization system (horstl.hs-fulda.de)
/// of the University Fulda.
library horstl_wrapper;

// TODO: Export any libraries intended for clients of this package.
export 'src/horstl_scrapper.dart';
export 'src/models/course.dart';
export 'src/models/day.dart';
export 'src/models/schedule.dart';
export 'src/models/menu.dart';
export 'src/models/dish.dart';
export 'src/util/week_of_year.dart';
