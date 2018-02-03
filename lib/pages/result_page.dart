import 'package:flutter/material.dart';
import 'search_page.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.bookmark), onPressed: null)
          ],
        ),
        body: new SingleChildScrollView(
            padding: new EdgeInsets.all(20.0),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Image(
                    image: new Image.network(bookResult.thumbLink).image,
                    width: 200.0,
                    height: 200.0,
                  ),
                  new Card(child: new Text(bookResult.title)),
                  new Card(
                    child: new Text(bookResult.author),
                  ),
                  new Card(
                      child: new Text(
                    bookResult.description,
                    style: new TextStyle(fontSize: 16.0, wordSpacing: 1.5),
                  )),
                ],
              ),
            )));
  }
}
