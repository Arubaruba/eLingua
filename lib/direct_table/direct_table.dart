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

  List<dynamic> documents = [];
  List<String> fieldNames = [];
  Map<String, dynamic> additionalDocument = {'doc':{}};
  bool readOnly = false;

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

  void loadDocuments({String id: '_all_docs'}) {
    http.get(couchDbQuery + '/$id', params: {'include_docs': true}).then((HttpResponse result) {
      //The Json file is automatically parsed in result.responseText
      if (result != null) {
        if (id.startsWith('_all_docs')) {
          documents.addAll(result.responseText['rows']);
        } else {
          dynamic existingDocument = documents.firstWhere(((dynamic document) => document['doc']['_id'] == id), orElse: (){
            documents.add({'doc': result.responseText});
          });
          if (existingDocument != null) {
            existingDocument['doc'] = result.responseText;
          }
        }
      } else {
        print('Direct Table failed to parse documents [${documents.length} - ${documents.length + amount - 1}] from "$couchDbQuery"');
      }
    }).catchError((error) {
      print(error);
      print('Direct Table failed to load documents [${documents.length} - ${documents.length + amount - 1}] from "$couchDbQuery"');
    });
  }

  void addDocument() {
    additionalDocument['doc']['created'] = new DateTime.now().millisecondsSinceEpoch;
    additionalDocument['processing'] = true;

    http.get(Config.couchDb + '_uuids?count=1').then((HttpResponse response) {

      String id = response.responseText['uuids'][0];

      http.put(couchDbQuery + '/' + id,
       JSON.encode(additionalDocument['doc']), headers:{'Content-Type':'application/json'}).then((HttpResponse response) {
        print(response);
        additionalDocument['processing'] = false;
        loadDocuments(id: id);
      }).catchError((error) {
        print(error);
        additionalDocument['processing'] = false;
      });

    }).catchError((error) {
      print(error);
      additionalDocument['processing'] = false;
    });
  }

  void backupDocument(Map<String, dynamic> document) {
    document['doc_backup'] = new Map.from(document['doc']);
  }

  void restoreDocument(Map<String, dynamic> document) {
    document['doc'] = document['doc_backup'];
  }

  void editDocument(dynamic document) {
    document['processing'] = true;
    String id = document['doc']['_id'];
    http.put(couchDbQuery + '/' + id,
    JSON.encode(document['doc']), headers:{'Content-Type':'application/json'}).then((HttpResponse response) {
      print(response);
      document['processing'] = false;
      document['edit'] = false;
      loadDocuments(id: id);
    }).catchError((error) {
      print(error);
      document['processing'] = false;
    });
  }
}
