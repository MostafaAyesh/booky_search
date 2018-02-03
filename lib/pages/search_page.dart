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

  var appBar = new AppBar(
      title: new Text("Searching ..."),
  );

  var bodyContent = new Center(
    child: new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Image.file(imageFile, width: 500.0, height: 500.0,),
        new CircularProgressIndicator()
      ],
    )
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: appBar,
      body: bodyContent,
      floatingActionButton: new FloatingActionButton(onPressed: (){
        searchImage(imageFile).then((result) {bookResult = result;});
      }),
    );
  }
}
