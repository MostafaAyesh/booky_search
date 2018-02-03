import "../lib/creds.dart";
import 'package:test/test.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/vision/v1.dart' as vis;
import 'package:googleapis/books/v1.dart' as bk;

const _SCOPES = const [bk.BooksApi.BooksScope];

vis.ImagesResourceApi visionApi = null;
bk.VolumesResourceApi booksApi = null;

void main() {
  test('Testing Creds', () {
    clientViaServiceAccount(credentials, _SCOPES).then((http_client) {
      booksApi = new bk.BooksApi(http_client).volumes;
      // var bookSearch = booksApi.list(q)
      expect(booksApi == null, false);
    });
  });
}
