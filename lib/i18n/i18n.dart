library i18n;

import 'package:angular/angular.dart';
import 'dart:html';

//Currently does nothing; however makes it much easier for i18n to be implemented
//later on

@Formatter(name: 'i')
class I18n {
  String call(String key) {
    return key;
  }
}
