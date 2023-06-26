import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TableStatus { idle, loading, ready, error }

enum ItemType { beer, coffee, nation, none }

class DataService {
  static const MAX_N_ITEMS = 15;
  static const MIN_N_ITEMS = 3;
  static const DEFAULT_N_ITEMS = 7;

  int _numberOfItems = DEFAULT_N_ITEMS;

  set numberOfItems(n){
    _numberOfItems = n < 0 ? MIN_N_ITEMS: n > MAX_N_ITEMS? MAX_N_ITEMS: n;
  }

  int get getNumberOfItems => _numberOfItems;
  

  final ValueNotifier<Map<String, dynamic>> tableStateNotifier = ValueNotifier({
    'status': TableStatus.idle,
    'dataObjects': [],
    'itemType': ItemType.none
  });

  final List<Map<String,dynamic>> apis = [
    {
      'api': 'api/coffee/random_coffee',
      'itemType': ItemType.coffee,
      'propertyNames': ["blend_name", "origin", "variety"],
      'columnNames': ["Nome", "Origem", "Tipo"]
    },
    {
      'api': 'api/beer/random_beer',
      'itemType': ItemType.beer,
      'propertyNames': ["name", "style", "ibu"],
      'columnNames': ["Nome", "Estilo", "IBU"]
    },
    {
      'api': 'api/nation/random_nation',
      'itemType': ItemType.nation,
      'propertyNames': ["nationality","capital","language","national_sport"],
      'columnNames': ["Nome", "Capital", "Idioma", "Esporte"]
    },    
  ];


  void carregar(index) {
    var apiSelect = apis[index];
    var api = apiSelect['api'];
    var item = apiSelect['itemType'];
    var propertyNames = apiSelect['propertyNames'];
    var columnNames = apiSelect['columnNames'];


    if (tableStateNotifier.value['status'] == TableStatus.loading) return;

    if (tableStateNotifier.value['itemType'] != item) {
      tableStateNotifier.value = {
        'status': TableStatus.loading,
        'dataObjects': [],
        'itemType': item
      };
    }

    var apiUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: api,
        queryParameters: {'size': '$_numberOfItems'});

    http.read(apiUri).then((jsonString) {
      var apiJson = jsonDecode(jsonString);

  
      if (tableStateNotifier.value['status'] != TableStatus.loading)
        apiJson = [
          ...tableStateNotifier.value['dataObjects'],
          ...apiJson
        ];

      tableStateNotifier.value = {
        'itemType': item,
        'status': TableStatus.ready,
        'dataObjects': apiJson,
        'propertyNames': propertyNames,
        'columnNames': columnNames
      };
    });
  }
}

final dataService = DataService();