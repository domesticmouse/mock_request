import 'dart:convert';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';

main() {
  var app = new Angel()
    ..get('/foo', (req, res) => 'Hello, world!')
    ..post('/body', (req, res) => req.parseBody().then((b) => b.length))
    ..get('/session', (req, res) async {
      req.session['foo'] = 'bar';
    })
    ..get('/conn', (RequestContext req, res) async {
      res.serialize(req.ip == InternetAddress.loopbackIPv4.address);
    });
  var http = new AngelHttp(app);

  test('receive a response', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/foo'));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(utf8.decoder).join(),
        equals(json.encode('Hello, world!')));
  });

  test('send a body', () async {
    var rq = new MockHttpRequest('POST', Uri.parse('/body'));
    rq
      ..headers.set(HttpHeaders.contentTypeHeader, ContentType.json.mimeType)
      ..write(json.encode({'foo': 'bar', 'bar': 'baz', 'baz': 'quux'}));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(utf8.decoder).join(), equals(json.encode(3)));
  });

  test('session', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/session'));
    await rq.close();
    await http.handleRequest(rq);
    expect(rq.session.keys, contains('foo'));
    expect(rq.session['foo'], equals('bar'));
  });

  test('connection info', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/conn'));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(await rs.transform(utf8.decoder).join(), equals(json.encode(true)));
  });

  test('requested uri', () {
    var rq = new MockHttpRequest('GET', Uri.parse('/mock'));
    expect(rq.uri.toString(), '/mock');
    expect(rq.requestedUri.toString(), 'http://example.com/mock');
  });
}
