library wait_for_view;

import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'dart:html';

@Decorator(selector: '[wait-for-view]')
class WaitForView {

  Element element;
  Router router;
  RootScope rootScope;

  WaitForView(this.router, this.rootScope, this.element) {
    router.root.onEnter.listen((dynamic event) {
      element.attributes.remove('wait-for-view');
    });
  }
}