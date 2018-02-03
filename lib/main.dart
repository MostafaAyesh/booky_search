import 'dart:async';

import 'package:flutter/material.dart';
import "package:Booky/pages/home_page.dart";
import "package:Booky/pages/search_page.dart";

void main() {
  runApp(new MaterialApp(
    home: new HomePage(),
    theme: new ThemeData(primarySwatch: Colors.blue),
    routes: {
      "/Search": (BuildContext context) => new SearchPage(),
    },
  ));
}