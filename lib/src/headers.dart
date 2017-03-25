import 'dart:io';

class MockHttpHeaders extends HttpHeaders {
  final Map<String, List<String>> _data = {};
  final List<String> _noFolding = [];

  List<String> get doNotFold => new List<String>.unmodifiable(_noFolding);

  ContentType get contentType {
    if (_data.containsKey(HttpHeaders.CONTENT_TYPE))
      return ContentType.parse(_data[HttpHeaders.CONTENT_TYPE].join(','));
    else
      return null;
  }

  void set contentType(ContentType value) =>
      set(HttpHeaders.CONTENT_TYPE, value.value);

  @override
  List<String> operator [](String name) => _data[name.toLowerCase()];

  @override
  void add(String name, Object value) {
    var lower = name.toLowerCase();

    if (_data.containsKey(lower)) {
      if (value is Iterable)
        _data[lower].addAll(value.map((x) => x.toString()).toList());
      else
        _data[lower].add(value.toString());
    } else {
      if (value is Iterable)
        _data[lower] = value.map((x) => x.toString()).toList();
      else
        _data[lower] = [value.toString()];
    }
  }

  @override
  void clear() {
    _data.clear();
  }

  @override
  void forEach(void f(String name, List<String> values)) {
    _data.forEach(f);
  }

  @override
  void noFolding(String name) {
    _noFolding.add(name.toLowerCase());
  }

  @override
  void remove(String name, Object value) {
    var lower = name.toLowerCase();

    if (_data.containsKey(lower)) {
      if (value is Iterable) {
        for (var x in value) {
          _data[lower].remove(x.toString());
        }
      } else
        _data[lower].remove(value.toString());
    }
  }

  @override
  void removeAll(String name) {
    _data.remove(name.toLowerCase());
  }

  @override
  void set(String name, Object value) {
    var lower = name.toLowerCase();
    _data.remove(lower);

    if (value is Iterable)
      _data[lower] = value.map((x) => x.toString()).toList();
    else
      _data[lower] = [value.toString()];
  }

  @override
  String value(String name) => _data[name.toLowerCase()]?.join(',');
}
