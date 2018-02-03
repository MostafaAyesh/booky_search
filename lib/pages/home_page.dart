import 'package:Booky/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

var imageFile;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  pickImage() async {
    ImagePicker.pickImage().then((value) {
      imageFile = value;
    }).whenComplete(() async {
      await new Future.delayed(new Duration(
          milliseconds:
              100)); // https://github.com/flutter/flutter/issues/13818
      Navigator.of(context).pushNamed("/Search");
    });
  }

  static final _pageTitle = "Home";

  static final bottomBarItems = [
    new BottomNavigationBarItem(
        icon: new Icon(Icons.home), title: new Text("Home")),
    new BottomNavigationBarItem(
        icon: new Icon(Icons.bookmark), title: new Text("Pins")),
    new BottomNavigationBarItem(
        icon: new Icon(Icons.settings), title: new Text("Settings"))
  ];

  var bottomBar = new BottomNavigationBar(
    items: bottomBarItems,
    type: BottomNavigationBarType.fixed,
    fixedColor: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_pageTitle),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            onPressed: null,
            tooltip: "Search",
          ),
          new IconButton(
              icon: new Icon(Icons.camera),
              onPressed: pickImage,
              tooltip: "Image Search")
        ],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
