import 'dart:async';
import 'dart:io';
import 'package:charcode/ascii.dart';
import 'connection_info.dart';
import 'lockable_headers.dart';
import 'response.dart';
import 'session.dart';

class MockHttpRequest extends Stream<List<int>>
    implements HttpRequest, StreamSink<List<int>>, StringSink {
  int _contentLength = 0;
  BytesBuilder _buf;
  final Completer _done = new Completer();
  final LockableMockHttpHeaders _headers = new LockableMockHttpHeaders();
  Uri _requestedUri;
  MockHttpSession _session;
  final StreamController<List<int>> _stream = new StreamController<List<int>>();

  @override
  final List<Cookie> cookies = [];

  @override
  HttpConnectionInfo connectionInfo =
      new MockHttpConnectionInfo(remoteAddress: InternetAddress.loopbackIPv4);

  @override
  MockHttpResponse response = new MockHttpResponse();

  @override
  HttpSession get session => _session;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  bool persistentConnection = true;

  /// [copyBuffer] corresponds to `copy` on the [BytesBuilder] constructor.
  MockHttpRequest(this.method, this.uri,
      {bool copyBuffer: true,
      String protocolVersion,
      String sessionId,
      this.certificate,
      this.persistentConnection}) {
    _buf = new BytesBuilder(copy: copyBuffer != false);
    _session = new MockHttpSession(id: sessionId ?? 'mock-http-session');
    this.protocolVersion =
        protocolVersion?.isNotEmpty == true ? protocolVersion : '1.1';
  }

  @override
  int get contentLength => _contentLength;

  @override
  HttpHeaders get headers => _headers;

  @override
  Uri get requestedUri {
    if (_requestedUri != null)
      return _requestedUri;
    else
      return _requestedUri = new Uri(
          scheme: 'http',
          host: 'example.com',
          path: uri.path,
          query: uri.query);
  }

  void set requestedUri(Uri value) {
    _requestedUri = value;
  }

  @override
  String protocolVersion;

  @override
  X509Certificate certificate;

  @override
  void add(List<int> data) {
    if (_done.isCompleted)
      throw new StateError('Cannot add to closed MockHttpRequest.');
    else {
      _headers.lock();
      _contentLength += data.length;
      _buf.add(data);
    }
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    if (_done.isCompleted)
      throw new StateError('Cannot add to closed MockHttpRequest.');
    else
      _stream.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    var c = new Completer();
    stream.listen(add, onError: addError, onDone: c.complete);
    return c.future;
  }

  @override
  Future close() async {
    await flush();
    _headers.lock();
    _stream.close();
    _done.complete();
    return await _done.future;
  }

  @override
  Future get done => _done.future;

  // @override
  Future flush() async {
    _contentLength += _buf.length;
    _stream.add(_buf.takeBytes());
  }

  @override
  void write(Object obj) {
    obj?.toString()?.codeUnits?.forEach(writeCharCode);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    write(objects.join(separator ?? ""));
  }

  @override
  void writeCharCode(int charCode) {
    add([charCode]);
  }

  @override
  void writeln([Object obj = ""]) {
    write(obj ?? "");
    add([$cr, $lf]);
  }

  @override
  Future<bool> any(bool test(List<int> element)) => _stream.stream.any(test);

  @override
  Stream<List<int>> asBroadcastStream(
          {void onListen(StreamSubscription<List<int>> subscription),
          void onCancel(StreamSubscription<List<int>> subscription)}) =>
      _stream.stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  @override
  Stream<E> asyncExpand<E>(Stream<E> convert(List<int> event)) =>
      _stream.stream.asyncExpand(convert);

  @override
  Stream<E> asyncMap<E>(FutureOr<E> convert(List<int> event)) =>
      _stream.stream.asyncMap(convert);

  @override
  Future<bool> contains(Object needle) => _stream.stream.contains(needle);

  @override
  Stream<List<int>> distinct(
          [bool equals(List<int> previous, List<int> next)]) =>
      _stream.stream.distinct(equals);

  @override
  Future<E> drain<E>([E futureValue]) => _stream.stream.drain(futureValue);

  @override
  Future<List<int>> elementAt(int index) => _stream.stream.elementAt(index);

  @override
  Future<bool> every(bool test(List<int> element)) =>
      _stream.stream.every(test);

  @override
  Stream<S> expand<S>(Iterable<S> convert(List<int> value)) =>
      _stream.stream.expand(convert);

  @override
  Future<List<int>> get first => _stream.stream.first;

  @override
  Future<List<int>> firstWhere(bool test(List<int> element),
          {List<int> orElse()}) =>
      _stream.stream.firstWhere(test, orElse: orElse);

  @override
  Future<S> fold<S>(S initialValue, S combine(S previous, List<int> element)) =>
      _stream.stream.fold(initialValue, combine);

  @override
  Future forEach(void action(List<int> element)) =>
      _stream.stream.forEach(action);

  @override
  Stream<List<int>> handleError(Function onError, {bool test(error)}) =>
      _stream.stream.handleError(onError, test: test);

  @override
  bool get isBroadcast => _stream.stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _stream.stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) =>
      _stream.stream.join(separator ?? "");

  @override
  Future<List<int>> get last => _stream.stream.last;

  @override
  Future<List<int>> lastWhere(bool test(List<int> element),
          {List<int> orElse()}) =>
      _stream.stream.lastWhere(test, orElse: orElse);

  @override
  Future<int> get length => _stream.stream.length;

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _stream.stream.listen(onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError == true);

  @override
  Stream<S> map<S>(S convert(List<int> event)) => _stream.stream.map(convert);

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) =>
      _stream.stream.pipe(streamConsumer);

  @override
  Future<List<int>> reduce(
          List<int> combine(List<int> previous, List<int> element)) =>
      _stream.stream.reduce(combine);

  @override
  Future<List<int>> get single => _stream.stream.single;

  @override
  Future<List<int>> singleWhere(bool test(List<int> element),
          {List<int> orElse()}) =>
      _stream.stream.singleWhere(test, orElse: orElse);

  @override
  Stream<List<int>> skip(int count) => _stream.stream.skip(count);

  @override
  Stream<List<int>> skipWhile(bool test(List<int> element)) =>
      _stream.stream.skipWhile(test);

  @override
  Stream<List<int>> take(int count) => _stream.stream.take(count);

  @override
  Stream<List<int>> takeWhile(bool test(List<int> element)) =>
      _stream.stream.takeWhile(test);

  @override
  Stream<List<int>> timeout(Duration timeLimit,
          {void onTimeout(EventSink<List<int>> sink)}) =>
      _stream.stream.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<List<int>>> toList() => _stream.stream.toList();

  @override
  Future<Set<List<int>>> toSet() => _stream.stream.toSet();

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) =>
      _stream.stream.transform(streamTransformer);

  @override
  Stream<List<int>> where(bool test(List<int> event)) =>
      _stream.stream.where(test);
}
