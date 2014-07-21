library elinga;

@MirrorsUsed(targets: const[
  'elingua'
],
override: '*')
import 'dart:mirrors';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:elingua/weekly_schedule/weekly_schedule.dart';
import 'package:elingua/sign_in.dart';
import 'package:elingua/i18n/i18n.dart';

class CoreModule extends Module {
  CoreModule() {
    type(SignIn);
    type(I18n);
  }
}

main() {
  applicationFactory().addModule(new CoreModule()).run();
}