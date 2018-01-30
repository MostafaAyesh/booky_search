import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart' as vis;
import 'package:googleapis/books/v1.dart' as bk;
import 'package:share/share.dart';


final _credentials = new ServiceAccountCredentials.fromJson(r'''''');

const _SCOPES = const [vis.VisionApi.CloudVisionScope, bk.BooksApi.BooksScope];

vis.ImagesResourceApi visionApi = null;
bk.VolumesResourceApi booksApi = null;
var mainDrawer = new Drawer(
  child: new ListView(
    children: <Widget>[
      new DrawerHeader(child: new Text("")),
    ],
  ),
);

void main() {
  clientViaServiceAccount(_credentials, _SCOPES).then((http_client) {
    visionApi = new vis.VisionApi(http_client).images;
    booksApi = new bk.BooksApi(http_client).volumes;
  });
  runApp(new MaterialApp(
      home: new MyHomePage(),
      routes: {"/Book": (BuildContext context) => new BookPage()}));
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
    var searchFeatures = [new vis.Feature()];
    searchFeatures[0].type = "WEB_DETECTION";
    searchFeatures[0].maxResults = 1;
    var imageRequest = new vis.AnnotateImageRequest();
    var imageApiFile = new vis.Image();
    imageApiFile.contentAsBytes = (imageFile.data).readAsBytesSync();
    imageRequest.image = imageApiFile;
    imageRequest.features = searchFeatures;
    var imageRequests = new vis.BatchAnnotateImagesRequest();
    imageRequests.requests = [imageRequest];
    vis.BatchAnnotateImagesResponse responses =
        await visionApi.annotate(imageRequests);
    List jsonResponses = responses.toJson()['responses'];
    var bookName =
        jsonResponses[0]['webDetection']['webEntities'][0]["description"];
    var bookSearchResults;
    await booksApi.list(bookName, maxResults: 1).then((volumes) {
      bookSearchResults = volumes.toJson();
      bookTitle = bookSearchResults['items'][0]['volumeInfo']["title"];
      authorName = bookSearchResults['items'][0]['volumeInfo']["authors"][0];
      bookDescription =
          bookSearchResults['items'][0]['volumeInfo']["description"];
      bookUrl = bookSearchResults['items'][0]['volumeInfo']["infoLink"];
      thumbURL = bookSearchResults['items'][0]['volumeInfo']["imageLinks"]['thumbnail'];
      Navigator.of(context).pushNamed("/Book");
    });
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

  @override
  Widget build(BuildContext context) {
    Future<Null> _launched;

    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
                actions: [
                  new IconButton(icon: new Icon(Icons.share), onPressed: (){
                    share("I found $bookTitle by $authorName using Booky! Link: $bookUrl");
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
                  new Container(child: new Image(image: new Image.network(thumbURL).image),decoration: new BoxDecoration(shape: BoxShape.rectangle)),
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
