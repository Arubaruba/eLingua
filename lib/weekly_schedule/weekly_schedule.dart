library weekly_schedule;

import 'package:angular/angular.dart';
import 'package:elingua/config.dart';
import 'dart:convert';

@Component(
  selector: 'weekly-schedule',
  templateUrl: '',
  cssUrl: '',
  publishAs: 'cmp')
class WeeklySchedule {

  final Http http;
  List<dynamic> appointments = [];

  WeeklySchedule(this.http) {
    http.get(Config.couchDb + '/appointments');
  }
}
