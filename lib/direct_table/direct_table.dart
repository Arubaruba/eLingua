library direct_table;

import 'package:angular/angular.dart';
import 'package:elingua/config.dart';
import 'dart:convert';

@Component(
  selector: 'direct_table',
  templateUrl: 'packages/elingua/direct_table/direct_table.html',
  cssUrl: 'packages/elingua/direct_table/direct_table.css',
  publishAs: 'cmp'
)
class DirectTable {

  Http http;
  Scope scope;

  String couchDbQuery = '';

  @NgOneWay('documents')
  List<dynamic> documents = [];
  List<String> fieldNames = [];

  DirectTable(this.http, this.scope) {
  }

  @NgAttr('couchdb-url')
  void set url(String value) {
    if (value == null) {
      print('Direct Table missing attribute "couchdb-url"');
    } else {
      couchDbQuery = Config.couchDb + value;
      loadDocuments();
    }
  }

  @NgAttr('fields')
  void set fields(String value) {
    if (value == null) {
      print('Direct Table missing attribute "fields"');
    } else {
      fieldNames = value.replaceAll(', ', ',').split(',');
    }
  }

  void loadDocuments({int amount: 10}) {
    http.get(couchDbQuery, params: {'include_docs': true}).then((HttpResponse result) {
      //The Json file is automatically parsed in result.responseText
      if (result != null) {
        documents.addAll(result.responseText['rows']);
      } else {
        print('Direct Table failed to parse documents [${documents.length} - ${documents.length + amount - 1}] from "$couchDbQuery"');
      }
    }).catchError((error) {
      print(error);
      print('Direct Table failed to load documents [${documents.length} - ${documents.length + amount - 1}] from "$couchDbQuery"');
    });
  }
}
