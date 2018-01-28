import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MaterialApp(
      home: new MyHomePage(),
      routes: {"/Book": (BuildContext context) => new BookPage()}));
}

const _auth =
    "ya29.c.El9QBRWzYt5DgNgFBQtcEtcwtnGX-OhPsQP7qavYCMJv5g21NaRqrQmWaroob1IINFNjUDRPZ1LLMv8vmaY-Ir9NN-hOi-xqul1KQBkX7X0K9DHGRGTtaAmAGsI-uggYOg";
const _apiKey = "AIzaSyCNKQcyPqgtEcXAHunIlrJc6N8jqrbJokA";
const _gapiKey = "pGVz089i9K8O82KYcaY2g";
var bookName = "";
var authorName = "";
var publisherName = "";
var bookDescription = "";
var bookUrl = "";
var imageLink = "";


Future<File> _imageFile;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> getLabel(String encodedImage) async {
    var _body =
        "{\"requests\": [{\"image\": {\"content\": \"$encodedImage\"},\"features\": [{\"type\": \"WEB_DETECTION\",\"maxResults\": 1}]}]}";
//  print("BODY: $_body");
    var request = await http.post(
        Uri.encodeFull("https://vision.googleapis.com/v1/images:annotate"),
        headers: {
          "Authorization": "Bearer $_auth",
        },
        body: _body.toString());
//  await io.sleep(new Duration(milliseconds: 5000));
    bookName = JSON.decode(request.body)["responses"][0]["webDetection"]
        ["webEntities"][0]["description"];
    print("Book Name: $bookName");
    var searchUrl =
        "https://www.googleapis.com/books/v1/volumes?q=$bookName&key=$_apiKey";
    await http.get(searchUrl).then(onValue);
  }

  void onValue(Response responseString) {
    publisherName =
        JSON.decode(responseString.body)['items'][0]['volumeInfo']["publisher"];
    bookDescription = JSON.decode(responseString.body)['items'][0]['volumeInfo']
        ["description"];
    print(JSON.decode(responseString.body)['items'][0]);
    switchPage();
  }

  String encodedImage;
  Future imageReq(String encI) async {
    await getLabel(encI);
  }

  @override
  void initState() {
    var bookName = "";
    var authorName = "";
    var publisherName = "";
    var bookDescription = "";

//    _imageFile = null;
    super.initState();
  }

  @override
  void dispose() {
//    _imageFile = null;
    super.dispose();
  }

  void switchPage() {
//    _imageFile = null;
    Navigator.of(context).pushNamed("/Book");
    deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Booky'),
      ),
      body: new Center(
          child: new FutureBuilder<File>(
              future: _imageFile,
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var img = (snapshot.data).readAsBytesSync();
                  String base64 = BASE64.encode(img) as String;
                  _imageFile = null;
                  encodedImage = base64 as String;

//                  print(encodedImage);
                  imageReq(encodedImage);

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
      await launch(url, forceSafariVC: true, forceWebView: true);
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
                leading: new IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/");
                    }),
                centerTitle: true,
                title: new Text("Search Results")),
            body: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
//            new Image(
                  new Card(
                      child: new Column(
                    children: <Widget>[
                      new Image(image: new AssetImage("assets/book.jpg"), width: 200.0, height: 200.0,),
                      new Padding(
                          child: new Text("$bookName",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14.0)),
                          padding: new EdgeInsets.all(20.0))
                    ],
                  )),
                  new Card(
                      child: new Padding(
                    child: new Row(
                      children: <Widget>[
                        new Text("Publisher:\t",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.0)),
                        new Text("$publisherName",
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
