library elinga;

@MirrorsUsed(targets: const[
  'elingua'
],
override: '*')
import 'dart:mirrors';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'package:elingua/direct_table/direct_table.dart';
import 'package:elingua/i18n/i18n.dart';

class CoreModule extends Module {
  CoreModule() {
    type(DirectTable);
    type(I18n);
  }
}

main() {
  applicationFactory().addModule(new CoreModule()).run();
}