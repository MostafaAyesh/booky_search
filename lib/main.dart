import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:googleapis/vision/v1.dart' as vis;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' as io;




//final _credentials = new ServiceAccountCredentials.fromJson(
//    {
//      "type": "service_account",
//      "project_id": "flutter-deltahacks",
//      "private_key_id": "e530ed8d566e13e6ea2a4fba05a86c2b950eca6f",
//      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzVjxEkufgvRMu\nDLAEyUjUMjOA5oDqF66nhMtnZMboBsPQadHn1vmIh+atBlhBHB3uzE5mNBXwJQOn\nPQLegoUzBo1+/OLqvXVT7mYLmH8/CIZ75x5oyWnpOiZ9ec1Aq5z4yuuDn0tgFaDf\nOOOEKcTpIkJNYT1cxTAfaZp0n8KuyJhK/LOQ6JP9yQvjGU+fEJck7IsOtXQWz85z\n9a2eTy+MjR33t2ZQ3ufxeF+lV0Pcf+2Zd6eEkm/knBsVmlZNRNp+aNOF/YAvZ4ih\nrhsh7hpKhf55G6tCXq1owpWDIV3WAWzLJAaQYFD3nn+3Qnoz3FDA3k+BCOFRy7DH\nFlnJwm3VAgMBAAECggEABng2seGb2F1xzvA5vF53kGIkPgLyxR8oF5aAkQEPdOjj\nkQX0QtkcROrkLTtEnUqyoL4BmQnJfdGUBWk7zIOoYvwaSCm+1OmTTT0VNNdiRcec\ntGUU0YJsnfORVmb5utrGDaqiXuv09+kn1c2zVX39QszP2ANJR6q8bvGsFwd5aj02\nWp08aJtFbMOPYcqaj8Y+XV0i/CMUYjXJ7ouIuzfC3Ct/xyVMrG/A4ILoxiywCBZi\nEvOwKanIK/tG+iqxT6VJIiQcMhb0M3EndOXB7M6xzuAgUqpLLRaViCdirJHum1VB\nGbu+3sZbEEB7RXu3PSgxCOr3PDbVHnX0DRcxMya96QKBgQDexBimLIGdw8usDZf7\nt86bkIEl8kT1AQ0tkgCKJcnm8ruRl9F+5PGu+VF9687xqjg/Nc3CZq2/oj529rF7\n/Uw3n5plbp/NMSGmlA6QjLKs6ot90jTpLNkc9jTNlBRXxKY4SE4EoKMlJ3AGBU/o\nY13ScyTsP24uLnq7NhDrpzIkXQKBgQDOF30MhBTh65jSKo9yc44WlXmff4/5+l+6\nDG8V6Jc/5E2Wl2IJ/cmCrddRyPdrsYt5S8lkVZUDOh1vjpvQcwsYQNqu7doG3feb\nnJw7IDIvFFozQS/rDbl4p4Lx0NRR+FvVvZ8ST8IrZUAmRP4auH2bOr+EGYGmrl3Q\n76iFnx5X2QKBgCb6MsHoqak8GAf7vOsLRzhK+X31PQGNdIvTrwp9AC3LrOwVn09P\nqcYO06Zvux7nxL2yoVTxeFc+gSV5lqZ2NH7LC03SJF3XyeaGo2HBbIX65/tU63Md\nKMP7hFOwJDsTKm5QoG4I2WLn2p8DEO89a64l/YDkvFeSRGE7XYyODaT1AoGAEM7n\nmvq2vUo6t4FTG7GC+CKOvcxokKmz3veeo7nJhCN5lHuaOlhhc+/7rKboTvc2+diN\nf0pfkdjOh8eou5J2aC755uRtMLwvsphOQaA5l49gX+fEIbaH1uhKjLBMcLcBvmft\nrk+k9WcXmUdtNf6v99YNwpdV9KMp8Z1qMCOvFNkCgYEAw71EsfaP5dEtHpD4AbLr\nKoTl2C8PjOwv+neI0LP3nf90+qzh5gXUB3fXfc1nDVVemdrsC5JXwmGs4kS0XUsP\n2eiMsQvQ9KPiVc+4yhQgspAwRBLaxhHzImV5lIiSqmQkdMrhfa8ckZS7B/Wb4Hjo\nGSziTZ5s1NyCxlqNde508D8=\n-----END PRIVATE KEY-----\n",
//      "client_email": "flutter-app@flutter-deltahacks.iam.gserviceaccount.com",
//      "client_id": "105438832750786687284",
//      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//      "token_uri": "https://accounts.google.com/o/oauth2/token",
//      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-app%40flutter-deltahacks.iam.gserviceaccount.com"
//    }


//);

//const _SCOPES = const [vis.VisionApi.CloudPlatformScope];
//var vision = null;
void main() {
//  clientViaServiceAccount(_credentials, _SCOPES).then((http_client) {
//    vision = new vis.VisionApi(http_client);
//  });
  runApp(new MaterialApp(home: new MyHomePage()));
}

Future<String> getLabel(String encodedImage) async {
  var request = await http.post(
    Uri.encodeFull("https://vision.googleapis.com/v1/images:annotate"),
    headers: {
      "Authorization": "Bearer ya29.c.El9QBRTU8B_BhCkVisr7qXfyLxBBPl2LttmKaGsfnBdfJTULDHPthykz-Mv_YuIiMJIIfRd0_AHIyNv7K6ItFa2GFOxWhlozrJ0fjEYfYOulBAZpvPUOcJLQL7MeJN908g",
    },
    body: {
      "requests": [
        {
          "image": {
            "content": encodedImage
          },
          "features": [
            {
              "type": "WEB_DETECTION",
              "maxResults": 1
            }
          ]
        }
      ]
    }
  );
//  await io.sleep(new Duration(milliseconds: 5000));
  print(request.body);
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> _imageFile;
  String encodedImage;
  Future imageReq(String encI) async {
    print("HELLO");
//    await getLabel(encI);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: new Center(
          child: new FutureBuilder<File>(
              future: _imageFile,
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var img = (snapshot.data).readAsBytesSync();
                  String base64 = BASE64.encode(img) as String;
                  encodedImage = base64 as String;

                  print(encodedImage);
                  imageReq(encodedImage);
                  return new Image.file(snapshot.data);
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