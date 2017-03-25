import 'dart:convert';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';

main() {
  var app = new Angel()
    ..get('/foo', 'Hello, world!')
    ..post('/body', (RequestContext req, res) async => req.body.length)
    ..get('/session', (RequestContext req, res) async {
      req.session['foo'] = 'bar';
    })
    ..get('/conn', (RequestContext req, res) async {
      res.serialize(req.ip == InternetAddress.LOOPBACK_IP_V4.address);
    });

  test('receive a response', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/foo'));
    await rq.close();
    await app.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(UTF8.decoder).join(),
        equals(JSON.encode('Hello, world!')));
  });

  test('send a body', () async {
    var rq = new MockHttpRequest('POST', Uri.parse('/body'));
    rq
      ..headers.set(HttpHeaders.CONTENT_TYPE, ContentType.JSON.mimeType)
      ..write(JSON.encode({'foo': 'bar', 'bar': 'baz', 'baz': 'quux'}));
    await rq.close();
    await app.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(UTF8.decoder).join(), equals(JSON.encode(3)));
  });

  test('session', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/session'));
    await rq.close();
    await app.handleRequest(rq);
    expect(rq.session.keys, contains('foo'));
    expect(rq.session['foo'], equals('bar'));
  });

  test('connection info', () async {
    var rq = new MockHttpRequest('GET', Uri.parse('/conn'));
    await rq.close();
    await app.handleRequest(rq);
    var rs = rq.response;
    expect(await rs.transform(UTF8.decoder).join(), equals(JSON.encode(true)));
  });
}
