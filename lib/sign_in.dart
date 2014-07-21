import 'package:angular/angular.dart';
import 'package:elingua/config.dart';
import 'package:elingua/i18n/i18n.dart';
import 'dart:convert';

@Controller(selector: '[sign-in]', publishAs: 'ctrl')
class SignIn {

  Http http;
  I18n i18n;

  String email = '', password = '';
  String error;

  bool signedIn = false;
  
  SignIn(this.http, this.i18n);
  
  authenticate() {
    error = null;
    http.post(Config.couchDb + '_session',
     JSON.encode({"name": email, "password": password})).then((HttpResponse response) {
      if (response.status == 200) {
        signedIn = true;
      }
    }).catchError((HttpResponse response) {
      if (response.status == 401) {
        error = i18n.call('Incorrect Email or Password');
      } else {
        error = i18n.call('Unable to Connect');
      }
    });
  }

  deauthenticate() {
    http.delete(Config.couchDb + '_session').then((HttpResponse response) {
      if (response.status == 200) signedIn = false;
    }).catchError((err) {
      print(err);
      print('Unable to sign out');
    });
  }
}
