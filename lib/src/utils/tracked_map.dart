/// A wrapper around [Map<String, dynamic>] that tracks the JSON key path
/// of every `[]` access. Nested maps and lists are also wrapped, so full
/// paths like `data.users[0].age` are recorded.
///
/// Usage:
/// ```dart
/// TrackedMap.lastAccessedPath = null;
/// final tracked = TrackedMap(jsonMap);
/// decoder(tracked); // if it crashes, check TrackedMap.lastAccessedPath
/// ```
class TrackedMap implements Map<String, dynamic> {
  TrackedMap(this._inner, [this._pathPrefix = '']);

  final Map<String, dynamic> _inner;
  final String _pathPrefix;

  /// Holds the most recently accessed key path (e.g. `data.users[0].age`).
  /// Reset this before each decode attempt.
  static String? lastAccessedPath;

  String _buildPath(String key) {
    if (_pathPrefix.isEmpty) {
      return key;
    }
    return '$_pathPrefix.$key';
  }

  @override
  dynamic operator [](Object? key) {
    final path = _buildPath(key.toString());
    lastAccessedPath = path;

    final value = _inner[key];
    return _wrapValue(value, path);
  }

  static dynamic _wrapValue(dynamic value, String path) {
    if (value is Map<String, dynamic>) {
      return TrackedMap(value, path);
    }
    if (value is List) {
      return _TrackedList(value, path);
    }
    return value;
  }

  // ── Delegated Map interface ──────────────────────────────────────────

  @override
  void operator []=(String key, dynamic value) => _inner[key] = value;

  @override
  void addAll(Map<String, dynamic> other) => _inner.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> entries) =>
      _inner.addEntries(entries);

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  void clear() => _inner.clear();

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  Iterable<MapEntry<String, dynamic>> get entries => _inner.entries;

  @override
  void forEach(void Function(String key, dynamic value) action) =>
      _inner.forEach(action);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<String> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  Map<K2, V2> map<K2, V2>(
          MapEntry<K2, V2> Function(String key, dynamic value) convert) =>
      _inner.map(convert);

  @override
  dynamic putIfAbsent(String key, dynamic Function() ifAbsent) =>
      _inner.putIfAbsent(key, ifAbsent);

  @override
  dynamic remove(Object? key) => _inner.remove(key);

  @override
  void removeWhere(bool Function(String key, dynamic value) test) =>
      _inner.removeWhere(test);

  @override
  dynamic update(String key, dynamic Function(dynamic value) update,
          {dynamic Function()? ifAbsent}) =>
      _inner.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(dynamic Function(String key, dynamic value) update) =>
      _inner.updateAll(update);

  @override
  Iterable<dynamic> get values => _inner.values;
}

/// A wrapper around [List] that tracks index-based access with paths
/// like `users[0]`, `users[1].name`, etc.
class _TrackedList<E> extends Iterable<E> implements List<E> {
  _TrackedList(this._inner, this._pathPrefix);

  final List<E> _inner;
  final String _pathPrefix;

  @override
  E operator [](int index) {
    final path = '$_pathPrefix[$index]';
    TrackedMap.lastAccessedPath = path;

    final value = _inner[index];
    return TrackedMap._wrapValue(value, path) as E;
  }

  // ── Delegated List interface ─────────────────────────────────────────

  @override
  void operator []=(int index, E value) => _inner[index] = value;

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) => _inner.length = newLength;

  @override
  void add(E value) => _inner.add(value);

  @override
  void addAll(Iterable<E> iterable) => _inner.addAll(iterable);

  @override
  bool any(bool Function(E element) test) => _inner.any(test);

  @override
  Map<int, E> asMap() => _inner.asMap();

  @override
  List<R> cast<R>() => _inner.cast<R>();

  @override
  void clear() => _inner.clear();

  @override
  bool contains(Object? element) => _inner.contains(element);

  @override
  E elementAt(int index) => _inner.elementAt(index);

  @override
  bool every(bool Function(E element) test) => _inner.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      _inner.expand(toElements);

  @override
  void fillRange(int start, int end, [E? fillValue]) =>
      _inner.fillRange(start, end, fillValue);

  @override
  E get first => _inner.first;

  @override
  set first(E value) => _inner.first = value;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      _inner.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => _inner.followedBy(other);

  @override
  void forEach(void Function(E element) action) => _inner.forEach(action);

  @override
  Iterable<E> getRange(int start, int end) => _inner.getRange(start, end);

  @override
  int indexOf(E element, [int start = 0]) => _inner.indexOf(element, start);

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) =>
      _inner.indexWhere(test, start);

  @override
  void insert(int index, E element) => _inner.insert(index, element);

  @override
  void insertAll(int index, Iterable<E> iterable) =>
      _inner.insertAll(index, iterable);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterator<E> get iterator => _inner.iterator;

  @override
  String join([String separator = '']) => _inner.join(separator);

  @override
  E get last => _inner.last;

  @override
  set last(E value) => _inner.last = value;

  @override
  int lastIndexOf(E element, [int? start]) =>
      _inner.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) =>
      _inner.lastIndexWhere(test, start);

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => _inner.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => _inner.reduce(combine);

  @override
  bool remove(Object? value) => _inner.remove(value);

  @override
  E removeAt(int index) => _inner.removeAt(index);

  @override
  void removeRange(int start, int end) => _inner.removeRange(start, end);

  @override
  E removeLast() => _inner.removeLast();

  @override
  void removeWhere(bool Function(E element) test) => _inner.removeWhere(test);

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) =>
      _inner.replaceRange(start, end, replacements);

  @override
  void retainWhere(bool Function(E element) test) => _inner.retainWhere(test);

  @override
  Iterable<E> get reversed => _inner.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) =>
      _inner.setAll(index, iterable);

  @override
  void setRange(int start, int end, Iterable<E> iterable,
          [int skipCount = 0]) =>
      _inner.setRange(start, end, iterable, skipCount);

  @override
  void shuffle([random]) => _inner.shuffle(random);

  @override
  E get single => _inner.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _inner.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _inner.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => _inner.skipWhile(test);

  @override
  void sort([int Function(E a, E b)? compare]) => _inner.sort(compare);

  @override
  List<E> sublist(int start, [int? end]) => _inner.sublist(start, end);

  @override
  Iterable<E> take(int count) => _inner.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => _inner.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => _inner.toList(growable: growable);

  @override
  Set<E> toSet() => _inner.toSet();

  @override
  Iterable<E> where(bool Function(E element) test) => _inner.where(test);

  @override
  Iterable<T> whereType<T>() => _inner.whereType<T>();

  @override
  List<E> operator +(List<E> other) => _inner + other;
}
