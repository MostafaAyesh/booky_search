import 'package:Booky/pages/result_page.dart';
import 'package:flutter/material.dart';
import 'package:Booky/pages/home_page.dart' show imageFile;
import 'package:Booky/util/image_search.dart';
import 'package:Booky/util/book_result.dart';

BookResult bookResult;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static var appBar = new AppBar(
    title: new Text("Searching ..."),
  );

  var bodyContent = new Center(
      child: new Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      new Image.file(
        imageFile,
        width: 500.0,
        height: 500.0,
      ),
      new CircularProgressIndicator()
    ],
  ));

  Widget defaultPage = new Scaffold(
    appBar: new AppBar(
      title: new Text("Searching ..."),
    ),
    body: new Center(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Image.file(
          imageFile,
          width: 500.0,
          height: 500.0,
        ),
        new CircularProgressIndicator()
      ],
    )),
  );

  reqSearch() async {
    bookResult = await searchImage(imageFile);
    setState(() {
      defaultPage = new ResultPage();
    });
  }

  @override
  initState() {
    reqSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return defaultPage;
  }
}
