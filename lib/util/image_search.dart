import 'dart:async';
import 'dart:io';
import 'package:googleapis/vision/v1.dart' as vis;
import 'package:googleapis/books/v1.dart' as bk;
import 'package:Booky/util/book_result.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:Booky/creds.dart';

vis.ImagesResourceApi visionApi;
bk.VolumesResourceApi booksApi;

const _SCOPES = const [vis.VisionApi.CloudVisionScope, bk.BooksApi.BooksScope];
Future<BookResult> searchImage(File imageFile) {
  return clientViaServiceAccount(credentials, _SCOPES).then((http_client) async{
    visionApi = new vis.VisionApi(http_client).images;
    booksApi = new bk.BooksApi(http_client).volumes;
    var request =  searchRequest(imageFile);
    return request.then((bookResult){return bookResult;});
  });
}

Future<BookResult> searchRequest(File imageFile) async {
  var searchFeatures = [new vis.Feature(), new vis.Feature()];
  searchFeatures[0].type = "LABEL_DETECTION";
  searchFeatures[0].maxResults = 1;
  searchFeatures[1].type = "WEB_DETECTION";
  searchFeatures[1].maxResults = 1;
  var imageRequest = new vis.AnnotateImageRequest();
  var imageApiFile = new vis.Image();
  imageApiFile.contentAsBytes = imageFile.readAsBytesSync();
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
    return booksApi.list(bookName, maxResults: 1).then((volumes) {

      // There is a null issue if one of the params doesn't exist
      // TODO: Fix Null Problem
      var volInfo = volumes.items[0].volumeInfo;
      var bookTitle = volInfo.title;
      var bookAuthor = volInfo.authors[0];
      var bookDesc = volInfo.description;
      var infoLink = volInfo.infoLink;
      var thumbLink = volInfo.imageLinks.thumbnail;
//      print(bookTitle);
      var retval = new BookResult(bookTitle, bookAuthor, bookDesc, infoLink, thumbLink);
      return retval;
    });
  } else {

  }
}