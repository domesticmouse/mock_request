# mock_request

[![version 1.0.1](https://img.shields.io/badge/pub-1.0.1-brightgreen.svg)](https://pub.dartlang.org/packages/mock_request)
[![build status](https://travis-ci.org/thosakwe/mock_request.svg)](https://travis-ci.org/thosakwe/mock_request)

Mock dart:io HttpRequests, HttpResponses, HttpHeaders, etc.
This makes it possible to test server-side Dart applications without
having to ever bind to a port.

This package was originally designed to testing
[Angel](https://github.com/angel-dart/angel/wiki)
applications smoother, but works with any Dart-based server. :)

# Usage
```dart
var rq = new MockHttpRequest('GET', Uri.parse('/foo'));
await rq.close();
await app.handleRequest(rq); // Run within your server-side application
var rs = rq.response;
expect(rs.statusCode, equals(200));
expect(await rs.transform(UTF8.decoder).join(),
    equals(JSON.encode('Hello, world!')));
```

More examples can be found in the included tests.