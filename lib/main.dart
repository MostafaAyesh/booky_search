import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart' as vis;
import 'package:googleapis/books/v1.dart' as bk;
import 'package:share/share.dart';
import 'creds.dart';
import "package:Booky/pages/home_page.dart";
import "package:Booky/pages/search_page.dart";
import "package:Booky/pages/result_page.dart";

const _SCOPES = const [vis.VisionApi.CloudVisionScope, bk.BooksApi.BooksScope];

vis.ImagesResourceApi visionApi;
bk.VolumesResourceApi booksApi;

var mainDrawer = new Drawer(
  child: new ListView(
    children: <Widget>[
      new DrawerHeader(child: new Text("")),
      new FlatButton(
        child: new Row(
          children: <Widget>[new Icon(Icons.history), new Text("History")],
        ),
        onPressed: () {},
      ),
    ],
  ),
);

void main() {
  clientViaServiceAccount(credentials, _SCOPES).then((http_client) {
    visionApi = new vis.VisionApi(http_client).images;
    booksApi = new bk.BooksApi(http_client).volumes;
  });
  runApp(new MaterialApp(
    home: new HomePage(),
    routes: {
      "/Search": (BuildContext context) => new SearchPage(),
      "/Result": (BuildContext context) => new ResultPage(),
    },
  ));
//  runApp(new MaterialApp(
//      home: new MyHomePage(),
//      routes: {"/Book": (BuildContext context) => new BookPage()}));
}

var bookName = "";
var bookTitle = "";
var authorName = "";
var publisherName = "";
var bookDescription = "";
var bookUrl = "";
var imageLink = "";
var thumbURL = "";

Future<File> _imageFile;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future searchRequest(AsyncSnapshot<File> imageFile) async {
    var searchFeatures = [new vis.Feature(), new vis.Feature()];
    searchFeatures[0].type = "LABEL_DETECTION";
    searchFeatures[0].maxResults = 1;
    searchFeatures[1].type = "WEB_DETECTION";
    searchFeatures[1].maxResults = 1;
    var imageRequest = new vis.AnnotateImageRequest();
    var imageApiFile = new vis.Image();
    imageApiFile.contentAsBytes = (imageFile.data).readAsBytesSync();
    imageRequest.image = imageApiFile;
    imageRequest.features = searchFeatures;
    var imageRequests = new vis.BatchAnnotateImagesRequest();
    imageRequests.requests = [imageRequest];
    vis.BatchAnnotateImagesResponse batchResponse =
        await visionApi.annotate(imageRequests);
    var imageDesc = batchResponse.responses[0].labelAnnotations[0].description;
    if (["book", "text", "font"].contains(imageDesc.toLowerCase())) {
      var bookName =
          batchResponse.responses[0].webDetection.bestGuessLabels[0].label;
      await booksApi.list(bookName, maxResults: 1).then((volumes) {
        var volInfo = volumes.items[0].volumeInfo;
        bookTitle = volInfo.title;
        authorName = volInfo.authors[0];
        bookDescription = volInfo.description;
        bookUrl = volInfo.infoLink;
        thumbURL = volInfo.imageLinks.thumbnail;
        Navigator.of(context).pushNamed("/Book");
      });
    } else {
      bookTitle = "NOT A BOOK";
      print(imageDesc);
      Navigator.of(context).pushNamed("/Book");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: mainDrawer,
      appBar: new AppBar(
        title: const Text('Booky'),
      ),
      body: new Center(
          child: new FutureBuilder<File>(
              future: _imageFile,
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  searchRequest(snapshot);
                  _imageFile = null;
                  return new CircularProgressIndicator();
                } else {
                  return const Text('You have not yet picked an image.');
                }
              })),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            _imageFile = ImagePicker.pickImage();
          });
        },
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => new _BookPageState();
}

class _BookPageState extends State<BookPage> {
  Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  // TODO: Using a builder to generate the search results
  // TODO: Redesign the layout and make it fit the width of the display
  @override
  Widget build(BuildContext context) {
    Future<Null> _launched;

    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
                actions: [
                  new IconButton(
                      icon: new Icon(Icons.share),
                      onPressed: () {
                        share(
                            "I found $bookTitle by $authorName using Booky! Link: $bookUrl");
                      })
                ],
                leading: new IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                centerTitle: true,
                title: new Text("Search Results")),
            body: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  new Container(
                      child:
                          new Image(image: new Image.network(thumbURL).image),
                      decoration: new BoxDecoration(shape: BoxShape.rectangle)),
                  new Card(
                      child: new Column(
                    children: <Widget>[
                      new Padding(
                          child: new Text("$bookTitle",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14.0)),
                          padding: new EdgeInsets.all(20.0))
                    ],
                  )),
                  new Card(
                      child: new Padding(
                    child: new Row(
                      children: <Widget>[
                        new Text("Author: ",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.0)),
                        new Text("$authorName",
                            style: new TextStyle(fontSize: 14.0))
                      ],
                    ),
                    padding: new EdgeInsets.all(20.0),
                  )),
                  new Card(
                      child: new Padding(
                          child: new Column(
                            children: <Widget>[
                              new Padding(
                                  child: new Text("Short Description",
                                      style: new TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold)),
                                  padding: new EdgeInsets.all(20.0)),
                              new Text("$bookDescription",
                                  style: new TextStyle(fontSize: 16.0))
                            ],
                          ),
                          padding: new EdgeInsets.all(20.0))),
                  new Card(
                      child: new RaisedButton(
                    child: new Padding(
                      child: new Text("Open On Google Books",
                          style: new TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold)),
                      padding: new EdgeInsets.all(20.0),
                    ),
                    onPressed: () {
                      setState(() {
                        _launched = _launchInWebViewOrVC(bookUrl);
                      });
                    },
                  ))
                ],
              ),
            )));
  }
}
