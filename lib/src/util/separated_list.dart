import 'package:petitparser/petitparser.dart';

/// Discards the [SeparatedList.separators] of the given [separatedList].
Iterable<E> discardSeparators<E, S>(SeparatedList<E, S> separatedList) =>
    separatedList.elements;
