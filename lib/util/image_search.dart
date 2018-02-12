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
Future<BookResult> searchImage(File imageFile) async {
  return clientViaServiceAccount(credentials, _SCOPES)
      .then((http_client) async {
    visionApi = new vis.VisionApi(http_client).images;
    booksApi = new bk.BooksApi(http_client).volumes;
    var request = await searchRequest(imageFile);
    return request;
  });
}

Future<BookResult> searchRequest(File imageFile) async {
  // Create AnnotateImageRequest
  var imageRequest = new vis.AnnotateImageRequest();

  // Setup Search Features
  var searchFeatures = [new vis.Feature(), new vis.Feature()];
  searchFeatures[0].type = "LABEL_DETECTION";
  searchFeatures[0].maxResults = 1;
  searchFeatures[1].type = "WEB_DETECTION";
  searchFeatures[1].maxResults = 1;
  imageRequest.features = searchFeatures;

  // Add the image to the request
  var imageApiFile = new vis.Image();
  imageApiFile.contentAsBytes = imageFile.readAsBytesSync();
  imageRequest.image = imageApiFile;

  // Create and submit BatchAnnotateImagesRequest
  var imageRequests = new vis.BatchAnnotateImagesRequest();
  imageRequests.requests = [imageRequest];
  vis.BatchAnnotateImagesResponse batchResponse =
      await visionApi.annotate(imageRequests);

  // Process the response and return the book result
  var imageDesc = batchResponse.responses[0].labelAnnotations[0].description; // Only the first response because we only have a single request
  if (["book", "text", "font"].contains(imageDesc.toLowerCase())) {
    var bookName =
        batchResponse.responses[0].webDetection.bestGuessLabels[0].label;
    return booksApi.list(bookName, maxResults: 1).then((volumes) {
      var volInfo = volumes.items[0].volumeInfo;
      // This handles nulls. Is there a cleaner way though?
      return new BookResult(
          title: volInfo.title ?? "No Title",
          author: volInfo.authors[0] ?? "No Author",
          description: volInfo.description ?? "No Description",
          infoLink: volInfo.infoLink ?? "https://google.com/",
          thumbLink: volInfo.imageLinks.thumbnail ??
              "http://via.placeholder.com/350x150");
    });
  } else {
    return null;
  }
}
