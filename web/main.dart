library elinga;

@MirrorsUsed(targets: const[
  'elingua'
],
override: '*')
import 'dart:mirrors';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/routing/module.dart';

import 'package:elingua/weekly_schedule/weekly_schedule.dart';
import 'package:elingua/i18n/i18n.dart';
import 'package:elingua/sign_in.dart';
import 'package:elingua/wait_for_view.dart';

class CoreModule extends Module {
  CoreModule() {
    bind(RouteInitializerFn, toValue: initRoutes);
    type(SignIn);
    type(WaitForView);
    type(I18n);
  }
}

void initRoutes(Router router, RouteViewFactory view) {
  router.root
    ..addRoute(name: 'sign-in', path: '/', enter: view('views/sign_in.html'))
    ..addRoute(name: 'password_reset', path: '/password_reset', enter: view('views/password_reset.html'))
    ..addRoute(name: 'signed-in', path: '/signed_in', enter: view('views/signed_in.html'),
        mount: (Route route) => route
          ..addRoute(defaultRoute: true, name: 'shedule', path: '/shedule', enter: view('views/schedule.html'))
      )
    ..addRoute(defaultRoute: true, name: 'page_not_found', path: '/page_not_found', enter: view('views/page_not_found.html'));
}

main() {
  applicationFactory().addModule(new CoreModule()).run();
}